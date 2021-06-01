function cite(name, key; cite_commands)
    cmd = get(cite_commands, key, "\\cite")
    cmd * "[" * name * "]" * "{" * key * "}"
end

function cite_package(name, bib; cite_commands)
    if length(bib) == 1
        key = only(keys(bib))
        cite(name, key; cite_commands)
    else

    end
end

function start_sentence(;cite_commands=Dict{String,String}())
    bib = import_bibtex(joinpath(@__DIR__, "julia.bib"))
    key = only(keys(bib))
    julia = cite("Julia v$VERSION", key; cite_commands)
    "This work was done in $julia and made use of the packages: "
end

function get_tool_citation(;cite_commands=Dict{String,String}())
    start = start_sentence(;cite_commands)
    pkg_citations = collect_citations()[2]

    pkg_citations = [cite(key, name; cite_commands) for name in keys(pkg_citations)]
end
