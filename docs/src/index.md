# ExactPredicates.jl

This package provides fast and robust predicates for Euclidean geometry, including `orient`, `incircle` and `insphere`.



## Robustness

**Robust** means that the code:

- raises an exception on `NaN` and `Inf` arguments;
- gives a correct answer on all other inputs with `Float64` coordinates, no matter what (overflow, underflow, etc.);
- in particular, no restriction on the coordinate range.

## Why robustness matter?

Even if the geometric data is approximate (for example when it comes from measurement),
robust computation is important because it guarantees *soundness* with respect to some combinatorial properties of the predicates.
For example `orient(a, b, c) == orient(b, c, a) == orient(c, a, b)`.

“Inexact versions of these tests *[orient and incircle]* are vulnerable to roundoff error, and the wrong
answers they produce can cause geometric algorithms to hang, crash, or produce
incorrect output.”

Jonathan Shewchuk, *Robust Adaptive Floating-point Geometric Predicates*


## Type for points

The basic type for representing points is `NTuple{N, Float64}`, where `N` is 2 or 3. Very concretly, that is `Tuple{Float64,Float64}` or `Tuple{Float64,Float64,Float64}`.

To define the predicates for a type `T`, simply define a function `Tuple(::T)` or
`coord(::T)` that output a `NTuple{N, Float64}` that contains the
coordinates. Naturally, the computation is only robust if the conversion is robust too.
There should be no performance penalty in the conversion.


```julia
using ExactPredicates
struct Point
    x :: Float64
    y :: Float64
end

Tuple(p :: Point) = (p.x, p.y)
incircle(Point(0.0, 0.0), Point(1.0, 0.0), Point(0.0, 1.0), Point(.5, .5))


coord(p :: Float64) = (p, 0.0)
coord(p :: Complex) = reim(p)
incircle(0.0, 1.0, complex(0.0, 1.0), complex(.5, .5))

using StaticArrays
# StaticArrays already defines Tuple for SVector
incircle(SVector(0.0, 0.0), SVector(1.0, 0.0), SVector(0.0, 1.0), SVector(.5, .5))
```


## License

The package is released under the MIT license.


## Exported functions

```@autodocs
Modules = [ExactPredicates]
```



