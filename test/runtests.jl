using Test

using ExactPredicates
import Base: complex

# easy tests


ExactPredicates.resetgenericcallcounter!()

@test ExactPredicates.genericcallcounter == 0
@test incircle(complex(0), complex(1), 1im, 1//2+im//2) == 1
@test incircle(complex(0), complex(1), 1im, 1+im) == 0
@test ExactPredicates.genericcallcounter == 2
@test incircle(complex(0.0), complex(1.0), 1.0im, .5+.5im) == 1
@test ExactPredicates.genericcallcounter == 2

@test orient(0.0, 1.0, 1.0im) == 1
@test ExactPredicates.genericcallcounter == 2

@test acuteangle(0.0, 1.0, 1.0im) == 0
@test acuteangle(0.0, 1.0, .1 + 1.0im) == 1
@test ExactPredicates.genericcallcounter == 2

# small pertubations

a = complex(0.0)
b = complex(1.0)
c = 1.0im

@test incircle(a, b, c, 0.0im) == 0
@test incircle(a, b, c, nextfloat(0.0)+0.0im) == 1
@test incircle(a, b, c, prevfloat(0.0)+0.0im) == -1

a = complex(2.0)
b = 1.0 + 1.0im
c = 1.0 - 1.0im

@test incircle(a, b, c, 0.0im) == 0
@test incircle(a, b, c, nextfloat(0.0)+0.0im) == 1
@test incircle(a, b, c, prevfloat(0.0)+0.0im) == -1


# collinear points

for i in 1:10
    rpts = rand(1:2^26, 4)
    pts = (rand(1:2^26) + rand(1:2^26)*im)*rpts
    fpts = convert(Vector{Complex{Float64}}, pts)
    @test incircle(fpts...) == 0
end



# genericity

struct Point
    x :: Float64
    y :: Float64
end

complex(p :: Point) = complex(p.x, p.y)

ExactPredicates.resetgenericcallcounter!()

@test ExactPredicates.genericcallcounter == 0
@test incircle(Point(0.0, 0.0), Point(1.0, 0.0), Point(0.0, 1.0), Point(.5, .5)) == 1
@test ExactPredicates.genericcallcounter == 0



