# API


The pseudo type `:: 2` indicate `Tuple{Float64,Float64}` or any type `T` such
that `ExactPredicates.coord(::T)` or `Base.Tuple(::T)` outputs a
`Tuple{Float64,Float64}`. Similaly, `:: 3` indicates
`Tuple{Float64,Float64,Float64}` or any type convertible to it `coord` or
`Tuple`.

```@autodocs
Modules = [ExactPredicates]
```


