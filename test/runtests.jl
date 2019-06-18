using Test

using ExactPredicates


# easy tests

@test incircle(complex(0), complex(1), 1im, 1//2+im//2) == 1
@test incircle(complex(0), complex(1), 1im, 1+im) == 0
@test incircle(complex(0.0), complex(1.0), 1.0im, .5+.5im) == 1


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
    @assert incircle(fpts...) == 0
end



