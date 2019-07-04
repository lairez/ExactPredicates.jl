
module Codegen

using IntervalArithmetic
using StaticArrays

import Base: +, *, -, one, convert, promote_rule


function adddict(a, b)
    d = copy(a)
    for k in keys(b)
        if haskey(a, k)
            d[k] += b[k]
        else
            d[k] = b[k]
        end
    end
    return d
end

function mergedict(a, b)
    d = copy(a)
    for k in keys(b)
        if haskey(a, k)
            d[k] = union(d[k], b[k])
        else
            d[k] = b[k]
        end
    end
    return d
end

mutable struct Formula <: Number
    id :: Symbol
    head :: Symbol
    args :: Vector
    group :: Union{Nothing, Symbol}
end

function Formula(name :: Union{Expr, Symbol}, group = nothing)
    s = gensym()
    Formula(s, :sym, [name], group)
end

macro var(args...)
    vars = [Formula(v) for v in args]
    Expr(:block,
         [Expr(:(=), esc(args[i]), vars[i]) for i in 1:length(vars)]...)
end

macro point2(args...)
    vars = [SVector(Formula(:($v[1])), Formula(:($v[2]))) for v in args]
    Expr(:block,
         [Expr(:(=), esc(args[i]), vars[i]) for i in 1:length(vars)]...)
end

function +(f :: Formula, g :: Formula)
    Formula(gensym(), :+, [f, g], nothing)
end

function *(f :: Formula, g :: Formula)
    Formula(gensym(), :*, [f, g], nothing)
end

function -(f :: Formula, g :: Formula)
    Formula(gensym(), :-, [f, g], nothing)
end

function -(f :: Formula)
    Formula(gensym(), :-, [f], nothing)
end



function convert(::Type{Formula}, i :: T) where T <: Integer
    Formula(gensym(), :const, [i], nothing)
end

zero(::Type{Formula}) = convert(Formula, 0)

promote_rule(::Type{T}, ::Type{Formula}) where {T <: Integer} = Formula


function group!(args...)
    @gensym g
    for f in args
        f.group = g
    end
end


function accumulator(f :: Formula)
    if f.head == :sym
        ret = (deg = Dict(), groups = Dict(), bound = Inf, error = 0.0)
    elseif f.head == :+ || (f.head == :- && length(f.args) == 2)
        af = accumulator(f.args[1])
        ag = accumulator(f.args[2])
        @assert af.deg == ag.deg

        #if f.head == :- && f.args[1].head == f.args[2].head == :sym
        #    k = first(keys(af.groups))
        #    return (deg = af.deg, groups = Dict(k => [f.id]), bound = 1.0, error = eps(1.0)/2)
        #else
        bound = nextfloat(af.bound + ag.bound)
        error = nextfloat(nextfloat(af.error + ag.error) + eps(bound)/2)
        ret = (deg = af.deg, groups = mergedict(af.groups, ag.groups), bound = bound, error = error)
        #end
    elseif f.head == :*
        af = accumulator(f.args[1])
        ag = accumulator(f.args[2])
        bound = nextfloat(af.bound * ag.bound)
        error = nextfloat(nextfloat(nextfloat(af.error*ag.bound) + nextfloat(af.bound*ag.error)) + eps(bound)/2)
        ret = (deg = adddict(af.deg, ag.deg), groups = mergedict(af.groups, ag.groups), bound = bound, error = error)
    elseif f.head == :-
        ret = accumulator(f.args[1])
    elseif f.head == :const
        ret = (deg = Dict(), groups = Dict(), bound = abs(float(f.args[1])), error = 0.0)
    else
        throw(DomainError())
    end

    if !isnothing(f.group)
        @assert f.head == :sym || f.head == :- && f.args[1].head == f.args[2].head == :sym
        ret = (deg = Dict(f.group => 1), groups = Dict(f.group => Set([f.id])), bound = 1.0, error = eps(1.0)/2)
    end

    return ret
end



function fpfilter(f :: Formula)
    acc = accumulator(f)

    code = []
    stack = [f]

    while !isempty(stack)
        e = pop!(stack)

        if e.head == :sym
            push!(code, Expr(:(=), e.id, e.args[1]))
        elseif e.head == :ref
            push!(code, Expr(:ref, e.id, e.args[1].id, e.args[2]))
            push!(stack, e.args[1])
        else
            push!(code, Expr(:(=), e.id, Expr(:call, e.head, (a.id for a in e.args)...)))
            push!(stack, e.args...)
        end
    end

    reverse!(code)


    for g in keys(acc.groups)
        as = [Expr(:call, :abs, v) for v in acc.groups[g]]
        push!(code, Expr(:(=), g, pop!(as)))
        for v in as
            @gensym b
            push!(code, :( $b = $v))
            push!(code, :( $g = ($g < $b) ? $b : $g ))
        end
        if acc.deg[g] != 1
            push!(code, Expr(:(=), g, Expr(:call, :^, g, acc.deg[g])))
        end
    end

    totdeg = +(values(acc.deg)...)

    @gensym e
    res = f.id

    quote
        $(code...)
        $e = $(acc.error * (1+eps(1.0))^totdeg)*$(Expr(:call, :*, keys(acc.groups)...))
        if $res < Inf && $e > $(floatmin(Float64))
            if $res > $e
                return 1
            elseif $res < $e
                return -1
            end
        end
    end

end




# function ivfilter(pred :: Predicate{Float64})
#     code = []
#     vars = []
#     for v in pred.vars
#         nv = gensym()
#         push!(vars, nv)
#         push!(code, :($v = $(interval)($nv)))
#     end

#     res = gensym()
#     ret = quote
#         $(code...)
#         $res = $(pred.code)
#         if $res > 0
#             return 1
#         elseif $res < 0
#             return -1
#         elseif $res == 0
#             return 0
#         end
#     end
#     return Predicate{Float64}(vars, ret)
# end


# function apcomputation(pred :: Predicate{Float64})
#     vars = []
#     code = []

#     for v in pred.vars
#         nv = gensym()
#         push!(vars, nv)
#         push!(code, :($v = Rational{BigInt}($nv)))
#     end

#     res = gensym()
#     ret = quote
#         $(code...)
#         $res = $(pred.code)
#         if $res > 0
#             return 1
#         elseif $res < 0
#             return -1
#         else
#             return 0
#         end
#     end
#     return Predicate{Float64}(vars, ret)
# end


# function fullstack(pred :: Predicate{Float64}, groups :: Vector{Vector{Symbol}})
#     stack(fpfilter(pred, groups), ivfilter(pred), apcomputation(pred))
# end

end

