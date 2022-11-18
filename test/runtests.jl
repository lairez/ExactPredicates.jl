using Test

using StaticArraysCore
using ExactPredicates
using ExactPredicates.Codegen
import Base: complex

import ExactPredicates: incircle_dbg, orient_dbg

p2(x, y=0.0) = (float(x), float(y))
p3(x, y=0, z=0) = (float(x), float(y), float(z))

@testset "easy" begin
    @test incircle(p2(0), p2(1), p2(0,1), p2(1/2,1/2)) == 1
    @test incircle(p2(0), p2(1), p2(0,1), p2(1,1)) == 0
    @test orient(p2(0.0), p2(1.0), p2(0.0,1.0)) == 1
    @test orient(p3(1.0), p3(0.0,1.0), p3(0,0,1.0), p3(0.0)) == 1
    @test insphere(p3(1.0), p3(0.0,1.0), p3(0,0,1.0), p3(0.0), p3(.5,.5,.5)) == 1
    @test closest(p2(0), p2(1), p2(0,1)) == 1
    @test closest(p3(0), p3(1), p3(0,1)) == 1
end


@testset "easy, with retcode" begin
    @test incircle_dbg(p2(0), p2(1), p2(0,1), p2(1/2,1/2)) == (1, Codegen.fastfp_flt)
    @test incircle_dbg(p2(0), p2(1), p2(0,1), p2(1,1)) == (0, Codegen.interval_flt)
    @test orient_dbg(p2(0.0), p2(1.0), p2(0.0,1.0)) == (1, Codegen.fastfp_flt)
end



@testset "perturbations" begin
    a = p2(0.0)
    b = p2(1.0)
    c = p2(0.0, 1.0)

    @test incircle_dbg(a, b, c, a) == (0, Codegen.zerotest_flt)
    @test incircle_dbg(a, b, c, b) == (0, Codegen.interval_flt)
    @test incircle_dbg(a, b, c, c) == (0, Codegen.interval_flt)
    @test incircle_dbg(a, b, b, c) == (0, Codegen.interval_flt)
    @test incircle(a, b, c, p2(nextfloat(0.0))) == 1
    @test incircle(a, b, c, p2(prevfloat(0.0))) == -1

    a = p2(2.0)
    b = p2(1.0, 1.0)
    c = p2(1.0, - 1.0)

    @test incircle(a, b, c, p2(0.0)) == 0
    @test incircle(a, b, c, p2(nextfloat(0.0))) == 1
    @test incircle(a, b, c, p2(prevfloat(0.0))) == -1
end


@testset "exactly collinear" begin
    for i in 1:10
        rpts = rand(1:2^26, 4)
        pts = (rand(1:2^26) + rand(1:2^26)*im)*rpts
        fpts = convert(Vector{Complex{Float64}}, pts)
        @test incircle_dbg(reinterpret(NTuple{2, Float64}, fpts)...) == (0, Codegen.exact_flt)
    end
end


@testset "exactly collinear (small integers)" begin
    for i in 1:10
        rpts = rand(1:2^5, 4)
        pts = (rand(1:2^5) + rand(1:2^5)*im)*rpts
        fpts = convert(Vector{Complex{Float64}}, pts)
        res, flt = incircle_dbg(reinterpret(NTuple{2, Float64}, fpts)...)
        @test res == 0
        @test flt ∈ [Codegen.zerotest_flt, Codegen.interval_flt]
    end
end


@testset "orient consistency" begin
    for i in 1:10
        a,b,c = randn(ComplexF64)*randn(Float64, 3)
        @test orient(a, b, c) == orient(b, c, a) == orient(c, a, b)
    end
end


@testset "fast zero detection" begin
    a, b, c, d = [reim(p) for p in randn(ComplexF64, 4)]
    @test orient_dbg(a, b, b) == (0, Codegen.zerotest_flt)
    @test orient_dbg(a, b, a) == (0, Codegen.zerotest_flt)
end

@testset "incircle consistency" begin
    for i in 1:10
        a,b,c,d = randn(ComplexF64)*[exp(x*im) for x in randn(Float64, 4)] .+ randn(ComplexF64)
        @test incircle(a,b,c,d) == -incircle(b,c,d,a) == incircle(c,d,a,b) == -incircle(d,a,b,c) == incircle(b,a,d,c) ==
            -incircle(a,c,b,d)
    end
end

@testset "orient3 consistency" begin
    for i in 1:10
        u, v, w = randn(SVector{3, SVector{3, Float64}})
        a = randn()*u + randn()*v + randn()*w
        @test orient(u, v, w, a) == -orient(v, w, a, u) == orient(w, a, u, v) == -orient(a, u, v, w) == orient(v, u, a, w)
    end
end

@testset "underflow incircle" begin
    p = randn(SVector{4, SVector{2, Float64}})

    s = Set()
    while all(abs(c) > floatmin(Float64) for r in p for c in r)
        push!(s, incircle(p...))
        p /= 2
    end

    @test length(s) == 1
end


@testset "overflow incircle" begin
    p = randn(SVector{4, SVector{2, Float64}})

    s = Set()
    while all(isfinite(c) for r in p for c in r)
        push!(s, incircle(p...))
        p *= 2
    end

    @test length(s) == 1
end

@testset "closest point 2d" begin
    a, b, p = (-264.2397483183316, -147.68399381193498),
    (-264.23974834572186, -147.68399391802012),
    (-264.2397478247797, -147.68399318319462)

    @test closest(a, b, p) == 1

    a, b, p =  (-754.9415749355259, 315.57575309957866),
    (-754.9415751576867, 315.5757530485543),
    (-754.9415749822347, 315.5757530017328)

    @test closest(a, b, p) == 1
end


import ExactPredicates: coord
struct Point{T}
    x :: T
    y :: T
end
coord(p :: Point) = (p.x, p.y)

@testset "genericity" begin
    @test incircle(Point(0.0,0.0), Point(1.0,0.0), Point(0.0, 1.0), Point(.5, 0.0)) == 1
end


@testset "parallelorder" begin
    for _ in 1:10
        a, b, c, d = randn(ComplexF64, 4)
        @test orient(a, b, c) == parallelorder(a, b, a, c)
    end
end


@testset "meet" begin
    for _ in 1:10
        t = [exp(im*2*pi*a) for a in sort(rand(4))]
        @test meet(t[1], t[2], t[3], t[4]) == -1
        @test meet(t[1], t[3], t[2], t[4]) == 1
        @test meet(t[1], t[3], t[3], t[4]) == 0
        @test meet(t[1], t[3], t[3], t[1]) == 0
    end

    @test meet(p2(0), p2(1), p2(3), p2(4)) == -1
    @test meet(p2(0), p2(3), p2(1), p2(4)) == 0
    @test meet(p2(1), p2(4), p2(1), p2(2)) == 0

    a = (0.0, 0.0)
    b = (2.0, 2.0)
    c = (-3., -8.)
    d = (-1., -1.)
    @test meet(a, b, c, d) == -1
    @test meet(c, d, a, b) == -1


end


@testset "rotation" begin
    angles = 3*pi*2*rand(30)
    sort!(angles)
    pts = [exp(im*α) for α in angles]
    @test rotation(pts) == 3
end


@testset "intersectorder" begin
    a, b, pa, pb, qa, qb = (complex(0.0), complex(1.0),
                            complex(0.0, 3.0), complex(2.0, 1.0),
                            complex(0.0, 2.0), complex(2.0, 1.0))

    @test intersectorder(a, b, pa, pb, qa, qb) == -1
    @test intersectorder(a, b, pb, pa, qa, qb) == 1

    for _ in 1:10
        a, b, pa, pb, qa, qb = randn(ComplexF64, 6)
        @test intersectorder(a, b, pa, pb, qa, qb) == intersectorder(qa, qb, a, b, pa, pb)
    end
end


