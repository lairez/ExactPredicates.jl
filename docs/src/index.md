# ExactPredicates.jl

This package provides two important predicates for geometry in the Euclidean plane: `orient` and `incircle`.

This package provides two important predicates for geometry in the Euclidean plane: `orient` and `incircle`.

They are ports in Julia of the [CGAL](https://www.cgal.org/) C++ predicates, implemented by Sylvain Pion.
They use floating point arithmetic and fallback to slow exact arithmetic when required. The algorithm has been proved robust and correct in a formal proof system by Guillaume Melquiond and Sylvain Pion ([“Formal certification of arithmetic filters for geometric predicates”](https://hal.inria.fr/inria-00344518), *IMACS 2005*) in all cases:

- underflows and overflows in the floating point computation;
- degenerate configurations (collinear points, colliding vertices, etc.).

## Robustness

**Robust** means that the code:

- raises an exception on `NaN` and `Inf` arguments;
- gives a correct answer on all other inputs with `Float64` coordinates, no matter what.

## Type for points

The basic type for representing points in the plane is `Complex{Float64}` (a.k.a. `ComplexF64`).
To define the predicates for a type `T`, simply define `complex(T)`.


```@example
using ExactPredicates
import Base: complex

struct Point
    x :: Float64
    y :: Float64
end

complex(p :: Point) = complex(p.x, p.y)

incircle(Point(0.0, 0.0), Point(1.0, 0.0), Point(0.0, 1.0), Point(.5, .5))
```


## License

The package is released under the LGPLv3 license, or any later version, as required by CGAL's license.


## Exported functions

```@docs
orient(p, q, r)
```

```@docs
incircle(a, b, c, p)
```



