```@meta
CurrentModule = PkgCite
```

# PkgCite

The [PkgCite](https://github.com/SebastianM-C/PkgCite.jl) julia package is useful for retrieving citation
information for julia packages. By convention, julia packages that have a paper (or some other citable
work associated) contain a CITATION.bib file in the root of the package directory. This package helps
user collect a .bib file corresponding to all the pacakges and their dependencies in [the current active
environment](https://pkgdocs.julialang.org/v1/environments/) and it also provides
and automatically generated sentence that references julia and the used packages.


## Usage

!!! note
    In order to give the most up to date citation information, PkgCite works with the packages in the
    [current active environment / project](https://pkgdocs.julialang.org/v1/environments/).
    Be sure to activate the desired environment before retrieving the citation data.

There are 2 main exported functions for this package: [`get_citations`](@ref) and [`get_tool_citation`](@ref).
If you only need a .bib file which concatenates all the CITATION.bib files of all the packages and their dependencies
in the current active environment, then you will only need [`get_citations`](@ref). Note that the generated .bib
file doesn't include [the citation for the Julia language itself](https://github.com/JuliaLang/julia/blob/master/CITATION.bib).

```@docs
get_citations
```

!!! tip
    When working on a new project / paper it is useful to [create a julia project](https://pkgdocs.julialang.org/v1/environments/#Creating-your-own-projects)
    to isolate the packages you use from other projects or the default environment. This will also [help others reproduce
    your results](https://pkgdocs.julialang.org/v1/environments/#Using-someone-else's-project) easier,
    since it they have your Project.toml and Manifest.toml files, with `]instantiate` they will
    get the exact same package versions as you do, elliminating thus problems with incompatible package versions.
    See also the [DrWatson](https://github.com/JuliaDynamics/DrWatson.jl) package, which can help you manage scientific projects.

If you also need to get the automatically generated sentence referencig julia, you will have to use [`get_tool_citation`](@ref).
```@docs
get_tool_citation
```
