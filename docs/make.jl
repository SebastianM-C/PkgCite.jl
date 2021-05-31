using Cite
using Documenter

DocMeta.setdocmeta!(Cite, :DocTestSetup, :(using Cite); recursive=true)

makedocs(;
    modules=[Cite],
    authors="Sebastian Micluța-Câmpeanu <m.c.sebastian95@gmail.com>",
    repo="https://github.com/SebastianM-C/Cite.jl/blob/{commit}{path}#{line}",
    sitename="Cite.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SebastianM-C.github.io/Cite.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SebastianM-C/Cite.jl",
)
