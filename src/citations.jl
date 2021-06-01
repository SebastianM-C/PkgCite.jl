function citation_path(pkg)
    bib_path = joinpath(pkg.source, "CITATION.bib")
    if isfile(bib_path)
        bib_path
    end
end

function get_citation(pkg)
    bib_path = citation_path(pkg)
    if !isnothing(bib_path)
        @debug "Reading CITATION.bib for $(pkg.name)"
        try
            import_bibtex(bib_path)
        catch e
            @warn("There was an error reading the CITATION.bib file for $(pkg.name)")
            @debug e
        end
    end
end

"""
    collect_citations()

Collect the citations from all the dependencies in the current environment.
"""
function collect_citations()
    @info "Generating citation report for the current environment"
    deps = Pkg.dependencies()
    all_citations = DataStructures.OrderedDict{String,Entry}()
    pkg_citations = Dict{String, DataStructures.OrderedDict{String,Entry}}()
    for pkg in values(deps)
        c = get_citation(pkg)
        if !isnothing(c)
            merge!(all_citations, c)
            push!(pkg_citations, pkg.name=>c)
        end
    end

    return all_citations, pkg_citations
end

"""
    get_citations(; filename="julia_citations.bib")

This will create a .bib file with all the citations collected form
the CITATION.bib files corresponding to the dependecies of
the current active environment. Use `filename` to change the name of the
file.
"""
function get_citations(;filename="julia_citations.bib")
    citations = collect_citations()[1]
    if isfile(filename)
        @warn "Overwriting $filename"
    end
    if isempty(citations)
        @warn "No citations found in current environment"
        return nothing
    end
    export_bibtex(filename, citations)
end
