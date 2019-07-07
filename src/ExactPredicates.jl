# SPDX-License-Identifier: MIT
# Author: Pierre Lairez

module ExactPredicates

export incircle, orient, closestpoint

include("Codegen.jl")

using StaticArrays
using IntervalArithmetic

using .Codegen: @genpredicates

const R2 = SVector{2}
const R3 = SVector{3}

ext(u :: R2, v :: R2) = u[1] * v[2] - u[2] * v[1]
inp(u :: R2, v :: R2) = u[1] * v[1] + u[2] * v[2]
inp(u :: R3, v :: R3) = u[1] * v[1] + u[2] * v[2] + u[3] * v[3]

det(a,b,c,d) = a*d-b*c
det(a,b,c,d,e,f,g,h,i) = a*det(e,f,h,i) - d*det(b,c,h,i) + g*det(b,c,e,f)


abs2(u :: SVector) = inp(u, u)

@genpredicates function orient(u :: 2, v :: 2, w :: 2)
    uw = u - w
    vw = v - w

    Codegen.group!(uw[1], vw[1])
    Codegen.group!(uw[1], vw[1])

    ext(uw, vw)
end

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



@genpredicates function closestpoint(p :: 2, q :: 2, a :: 2)
    pq = p - q
    pa = p - q
    qa = q - a

    Codegen.group!(pq...)
    Codegen.group!(pa..., qa...)

    inp(pq, pa+qa)
end

@genpredicates function closestpoint(p :: 3, q :: 3, a :: 3)
    pq = p - q
    pa = p - q
    qa = q - a

    Codegen.group!(pq...)
    Codegen.group!(pa..., qa...)

    inp(pq, pa+qa)
end

@genpredicates function orient(p :: 3, q :: 3, r :: 3, a :: 3)
    pa = p - a
    qa = q - a
    ra = r - a

    Codegen.group!(pa...)
    Codegen.group!(qa...)
    Codegen.group!(ra...)

    det(pa..., qa..., ra...)
end



end


