using PkgCite
using Documenter

DocMeta.setdocmeta!(PkgCite, :DocTestSetup, :(using PkgCite); recursive=true)

makedocs(;
    modules=[PkgCite],
    authors="Sebastian Micluța-Câmpeanu <m.c.sebastian95@gmail.com>",
    repo="https://github.com/SebastianM-C/PkgCite.jl/blob/{commit}{path}#{line}",
    sitename="PkgCite.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SebastianM-C.github.io/PkgCite.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SebastianM-C/PkgCite.jl",
)
