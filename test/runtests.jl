using Test

using StaticArrays
using ExactPredicates
using ExactPredicates.Codegen
import Base: complex

import ExactPredicates: incircle_dbg, orient_dbg

p2(x, y=0.0) = SVector(float(x), float(y))

@testset "easy" begin
    @test incircle(p2(0), p2(1), p2(0,1), p2(1/2,1/2)) == 1
    @test incircle(p2(0), p2(1), p2(0,1), p2(1,1)) == 0
    @test orient(p2(0.0), p2(1.0), p2(0.0,1.0)) == 1
end


@testset "easy, with retcode" begin
    @test incircle_dbg(p2(0), p2(1), p2(0,1), p2(1/2,1/2)) == (1, Codegen.fastfp_flt)
    @test incircle_dbg(p2(0), p2(1), p2(0,1), p2(1,1)) == (0, Codegen.interval_flt)
    @test orient_dbg(p2(0.0), p2(1.0), p2(0.0,1.0)) == (1, Codegen.fastfp_flt)
end



@testset "pertubations" begin
    a = p2(0.0)
    b = p2(1.0)
    c = p2(0.0, 1.0)

    @test incircle_dbg(a, b, c, a) == (0, Codegen.zerotest_flt)
    @test incircle_dbg(a, b, c, b) == (0, Codegen.interval_flt)
    @test incircle_dbg(a, b, c, c) == (0, Codegen.interval_flt)
    @test incircle_dbg(a, b, b, c) == (0, Codegen.interval_flt)
    @test incircle_dbg(a, b, c, p2(nextfloat(0.0))) == (1, Codegen.interval_flt)
    @test incircle_dbg(a, b, c, p2(prevfloat(0.0))) == (-1, Codegen.interval_flt)

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
        @test incircle_dbg(reinterpret(SVector{2, Float64}, fpts)...) == (0, Codegen.exact_flt)
    end
end


@testset "orient consistency" begin
    for i in 1:10
        a,b,c = randn(ComplexF64)*randn(Float64, 3)
        @test orient(a, b, c) == orient(b, c, a) == orient(c, a, b)
    end
end


@testset "incircle consistency" begin
    for i in 1:10
        a,b,c,d = randn(ComplexF64)*[exp(x*im) for x in randn(Float64, 4)] .+ randn(ComplexF64)
        @test incircle(a,b,c,d) == -incircle(b,c,d,a) == incircle(c,d,a,b) == -incircle(d,a,b,c) == incircle(b,a,d,c) ==
            -incircle(a,c,b,d)
    end
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


