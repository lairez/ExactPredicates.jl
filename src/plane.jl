# SPDX-License-Identifier: MIT
# Author: Pierre Lairez



@genpredicate function orient(u :: 2, v :: 2, w :: 2)
    u = u - w
    v = v - w

    Codegen.group!(u[1], v[1])
    Codegen.group!(u[2], v[2])

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
