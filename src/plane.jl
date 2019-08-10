# SPDX-License-Identifier: MIT
# Author: Pierre Lairez



@genpredicate function orient(u :: 2, v :: 2, w :: 2)
    u = u - w
    v = v - w

    Codegen.group!(u...)
    Codegen.group!(v...)

    ext(u, v)
end
@doc """

    orient(p :: 2, q :: 2, r :: 2) -> Int

* Return 1 if `r` is on the left of the oriented line defined by `p` and `q`.
* Return –1 if `r` is on the right.
* Return 0 if `r` is on the line or if `p == q`.

""" orient(::NTuple{2, Float64}, ::NTuple{2, Float64}, ::NTuple{2, Float64})


@genpredicate function incircle(p :: 2, q :: 2, r :: 2, a :: 2)

    qp = q - p
    rp = r - p
    ap = a - p
    aq = a - q
    rq = r - q

    Codegen.group!(qp...)
    Codegen.group!(ap...)
    Codegen.group!(rp...)
    Codegen.group!(rq..., aq...)

    ext(qp, ap)*inp(rp, rq) - ext(qp, rp)*inp(ap, aq)
end
@doc """
    incircle(a :: 2, b :: 2, c :: 2, p :: 2) -> Int


Assume that `a`, `b` and `c` define a counterclockwise triangle.

* Return 1 if `p` is strictly inside the circumcircle of this triangle.
* Return –1 if `p` is outside.
* Return 0 if `p` is on the circle.

If the triangle is oriented clockwise, the signs are reversed.
If `a`, `b` and `c` are collinear, this degenerate to an orientation test.

If two of the four arguments are equal, return 0.

""" incircle(::NTuple{2, Float64}, ::NTuple{2, Float64}, ::NTuple{2, Float64}, ::NTuple{2, Float64})


@genpredicate function incircle2(a :: 2, b :: 2, c :: 2, p :: 2)
    a = a - p
    b = b - p
    c = c - p

    Codegen.group!(a..., b..., c...)
    abs2(a)*ext(b, c) + abs2(b)*ext(c, a) + abs2(c)*ext(a, b)
end



@genpredicate function closest(p :: 2, q :: 2, a :: 2)
    qp = q - p
    pa = p - a
    qa = q - a

    Codegen.group!(qp...)
    Codegen.group!(pa..., qa...)

    inp(qp, pa+qa)
end
@doc """
    closest(p :: 2, q :: 2, a :: 2) -> Int

* Return 1 if `a` is closer to `p` than to `q`.
* Return –1 if `a` is closer to `q` than to `p`.
* Return 0 is `a` is equaly close to both.
""" closest(::NTuple{2, Float64}, ::NTuple{2, Float64}, ::NTuple{2, Float64})



"""
    sameside(p :: 2, a :: 2, b :: 2)

Assume that the three arguments are collinear, on some line L

* Return 1 if `a` and `b` are on the same side of `p` on L
* Return -1 if `a` and `b` are on different sides
* Return 0 if `a == p` or `b == p`.
"""
function sameside(p :: Tuple{Float64, Float64}, a :: Tuple{Float64, Float64}, b :: Tuple{Float64, Float64})
    if a[1] > p[1] && b[1] > p[1] || a[1] < p[1] && b[1] < p[1]
        return 1
    elseif a[1] < p[1] && b[1] > p[1] || a[1] > p[1] && b[1] < p[1]
        return -1
    elseif a[2] > p[2] && b[2] > p[2] || a[2] < p[2] && b[2] < p[2]
        return 1
    elseif a[2] < p[2] && b[2] > p[2] || a[2] > p[2] && b[2] < p[2]
        return -1
    else
        return 0
    end
end

function sameside(p, a, b)
    sameside(coord(p), coord(a), coord(b))
end

"""
    meet(p :: 2, q :: 2, a :: 2, b :: 2)

* Return 1 if the open line segments `(p, q)` and `(a, b)` meet in a single point.
* Return 0 if the the closed line segments `[p, a]` and `[a, b]` meet in one or several points.
* Return –1 otherwise.
"""
function meet(p, q, a, b)
    pqa = orient(p, q, a)
    pqb = orient(p, q, b)
    abp = orient(a, b, p)
    abq = orient(a, b, q)

    if opposite_signs(pqa, pqb) && opposite_signs(abp, abq)
        return 1
    elseif pqa & pqb == 1 || abp & abq == 1
        return -1
    elseif pqa == 0 && pqb == 0
        # all four points are collinear
        if sameside(p, a, b) == 1 && sameside(q, a, b) == 1 && sameside(a, p, q) == 1 && sameside(b, p, q) == 1
            return -1
        else
            return 0
        end
    else
        return 0
    end
end



@genpredicate function relative_orient(a :: 2, b :: 2, p :: 2, q :: 2)
    b = b - a
    q = q - p
    Codegen.group!(b...)
    Codegen.group!(q...)
    return ext(b, q)
end


function rotation(pts :: AbstractVector{T}) where T
    u = rand(SVector{2, Float64})
    origin = (0.0, 0.0)

    n = length(pts)
    @assert n >= 3

    pts = copy(pts)
    push!(pts, pts[1], pts[2])

    r = 0
    o1 = relative_orient(origin, u, pts[1], pts[2])
    for i in 1:n
        o2 = relative_orient(origin, u, pts[i+1], pts[i+2])
        if opposite_signs(o1, o2)
            ro = relative_orient(pts[i], pts[i+1], pts[i+1], pts[i+2])
            @assert ro != 0
            if ro > 0 && o1 < 0
                r += 1
            elseif ro < 0 && o1 > 0
                r -= 1
            end
        end
        o1 = o2
    end

    return r
end



