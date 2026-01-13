using PkgCite
using Documenter
using Documenter.Remotes: GitHub

DocMeta.setdocmeta!(PkgCite, :DocTestSetup, :(using PkgCite); recursive=true)

makedocs(;
    modules=[PkgCite],
    authors="Sebastian Micluța-Câmpeanu <m.c.sebastian95@gmail.com>",
    repo=GitHub("SebastianM-C/PkgCite.jl"),
    sitename="PkgCite.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SebastianM-C.github.io/PkgCite.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    warnonly=[:missing_docs],
)

deploydocs(;
    repo="github.com/SebastianM-C/PkgCite.jl",
)
