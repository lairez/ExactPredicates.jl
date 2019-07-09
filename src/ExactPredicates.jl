# SPDX-License-Identifier: MIT
# Author: Pierre Lairez

module ExactPredicates

export incircle, orient, closestpoint, insphere

include("Codegen.jl")

using StaticArrays
using IntervalArithmetic

using .Codegen
import .Codegen: coord

export coord

const R2 = SVector{2}
const R3 = SVector{3}

ext(u :: R2, v :: R2) = u[1] * v[2] - u[2] * v[1]
inp(u :: R2, v :: R2) = u[1] * v[1] + u[2] * v[2]
inp(u :: R3, v :: R3) = u[1] * v[1] + u[2] * v[2] + u[3] * v[3]

det(a,b,c,d) = a*d-b*c
det(a,b,c,d,e,f,g,h,i) = a*det(e,f,h,i) - d*det(b,c,h,i) + g*det(b,c,e,f)


@inline function det(m1, m5, m9, m13, m2, m6, m10, m14, m3, m7, m11, m15, m4, m8, m12, m16)
    p34 = m11*m16 - m12*m15
    p23 = m10*m15 - m11*m14
    p12 = m9 *m14 - m10*m13
    p13 = m9 *m15 - m11*m13
    p14 = m9 *m16 - m12*m13
    p24 = m10*m16 - m12*m14
    return (
          m1*(m6*p34 - m7*p24 + m8*p23)
        - m2*(m5*p34 - m7*p14 + m8*p13)
        + m3*(m5*p24 - m6*p14 + m8*p12)
        - m4*(m5*p23 - m6*p13 + m7*p12)
    )
end


abs2(u :: SVector) = inp(u, u)

"""

    orient(p :: 2, q :: 2, r :: 2) -> Int

* Return 1 if `r` is on the left of the oriented line defined by `p` and `q`.
* Return –1 if `r` is on the right.
* Return 0 if `r` is on the line or if `p == q`.

"""
@genpredicates function orient(u :: 2, v :: 2, w :: 2)
    u = u - w
    v = v - w

    Codegen.group!(u[1], v[1])
    Codegen.group!(u[2], v[2])

    ext(u, v)
end


"""
    incircle(a :: 2, b :: 2, c :: 2, p :: 2) -> Int


Assume that `a`, `b` and `c` define a counterclockwise triangle.

* Return 1 if `p` is strictly inside the circumcircle of this triangle.
* Return –1 if `p` is outside.
* Return 0 if `p` is on the circle.

If the triangle is oriented clockwise, the signs are reversed.
If `a`, `b` and `c` are collinear, this degenerate to an orientation test.

If two of the four arguments are equal, return 0.

"""
@genpredicates function incircle(p :: 2, q :: 2, r :: 2, a :: 2)

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


@genpredicates function incircle2(a :: 2, b :: 2, c :: 2, p :: 2)
    a = a - p
    b = b - p
    c = c - p

    Codegen.group!(a..., b..., c...)
    abs2(a)*ext(b, c) + abs2(b)*ext(c, a) + abs2(c)*ext(a, b)
end

"""
    closestpoint(p :: 2, q :: 2, a :: 2) -> Int

* Return 1 if `a` is closer to `p` than to `q`.
* Return –1 if `a` is closer to `q` than to `p`.
* Return 0 is `a` is equaly close to both.
"""
@genpredicates function closestpoint(p :: 2, q :: 2, a :: 2)
    pq = p - q
    pa = p - q
    qa = q - a

    Codegen.group!(pq...)
    Codegen.group!(pa..., qa...)

    inp(pq, pa+qa)
end

"""
    closestpoint(p :: 3, q :: 3, a :: 3) -> Int

Return 1 if `a` is closer to `p` than to `q`.
Return –1 if `a` is closer to `q` than to `p`.
Return 0 is `a` is equaly close to both.
"""
@genpredicates nogeneric function closestpoint(p :: 3, q :: 3, a :: 3)
    pq = p - q
    pa = p - q
    qa = q - a

    Codegen.group!(pq...)
    Codegen.group!(pa..., qa...)

    inp(pq, pa+qa)
end

"""
    orient(p :: 3, q :: 3, r :: 3, a :: 3) -> Int

Consider the oriented plane on which the triangle `pqr` is positively oriented.

* Return 1 if `a` is below this plane.
* Return –1 if `a` is above this plane.
* Return 0 if `a` lies on this plane.

"""
@genpredicates function orient(p :: 3, q :: 3, r :: 3, a :: 3)
    pa = p - a
    qa = q - a
    ra = r - a

    Codegen.group!(pa...)
    Codegen.group!(qa...)
    Codegen.group!(ra...)

    det(pa..., qa..., ra...)
end

"""
    insphere(p :: 3, q :: 3, r :: 3, s :: 3, a :: 3)

* Return 1 if `a` is inside the circumscribed sphere defined by the four points `p`, `q`, `r` and `s`.
* Return –1 if `a` is outside.
* Return 0 is `a` lies on the sphere or if the four points are coplanar.

"""
@genpredicates function insphere(p :: 3, q :: 3, r :: 3, s :: 3, a :: 3)
    p = p - a
    q = q - a
    r = r - a
    s = s - a

    Codegen.group!(p..., q..., r..., s...)

    det(p..., abs2(p), q..., abs2(q), r..., abs2(r), s..., abs2(s))
end



end
