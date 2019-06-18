# ExactPredicates.jl

This package provides two important predicates for geometry in the Euclidean plane: `orient` and `incircle`.

They are ports in Julia of the [CGAL](https://www.cgal.org/) C++ predicates, implemented by Sylvain Pion and Guillaume Melquiond.
They use floating point arithmetic and fallback to slow exact arithmetic when required. The algorithm has been proved robust and correct in a formal proof system by Melquiond and Pion ([“Formal certification of arithmetic filters for geometric predicates”](https://hal.inria.fr/inria-00344518), *IMACS 2005*), even when underflows or overflows happen.

Points in the plane are represented by the `ComplexF64` type.


```@docs
orient(p :: ComplexF64, q :: ComplexF64, r :: ComplexF64)
```

```@docs
orient(p :: Complex, q :: Complex, r :: Complex)
```

```@docs
    incircle(a :: ComplexF64, b :: ComplexF64, c :: ComplexF64, p :: ComplexF64)
```

```@docs
    incircle(a :: Complex, b :: Complex, c :: Complex, p :: Complex)
```



