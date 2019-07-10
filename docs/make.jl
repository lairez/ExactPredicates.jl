push!(LOAD_PATH, "../src/")

using Documenter, ExactPredicates

makedocs(sitename="ExactPredicates.jl",
         pages = ["index.md", "api.md"],
         repo = "https://github.com/lairez/ExactPredicates.jl/blob/{commit}{path}#{line}")

