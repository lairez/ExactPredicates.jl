# SPDX-License-Identifier: MIT
# Author: Pierre Lairez

module ExactPredicates


include("Codegen.jl")

using StaticArrays
using IntervalArithmetic

using .Codegen: @genpredicates

const R2 = SVector{2}

ext(u, v) = u[1] * v[2] - u[2] * v[1]
inp(u, v) = u[1] * v[1] + u[2] * v[2]
abs2(u :: R2) = inp(u, u)

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

end


