function citation_path(pkg)
    bib_path = joinpath(pkg.source, "CITATION.bib")
    if isfile(bib_path)
        bib_path
    end
end


# Added `zenodo` flag to avoid breaking current tests
function get_citation(pkg; zenodo=false)
    bib_path = citation_path(pkg)
    if zenodo == false
        urlzenodo = nothing
    else
        urlzenodo = get_zenodo_badge(pkg)
    end
    if !isnothing(bib_path)
        @debug "Reading CITATION.bib for $(pkg.name)"
        try
            import_bibtex(bib_path)
        catch e
            @warn "There was an error reading the CITATION.bib file for $(pkg.name)" exception=e
        end
    elseif !isnothing(urlzenodo)
        get_citation_zenodo(urlzenodo)
    end
end

"""
    collect_citations(only_direct::Bool; zenodo=false)

Collect the citations from all the dependencies in the current environment.
Use `zenodo = true` to get the citations from packages without
a `Citation.bib` file, but with a Zenodo's badge.
"""
function collect_citations(only_direct::Bool; zenodo=false)
    @debug "Generating citation report for the current environment"
    deps = Pkg.dependencies()
    pkg_citations = Dict{String, DataStructures.OrderedDict{String,Entry}}()
    for pkg in values(deps)
        if only_direct && !pkg.is_direct_dep
            continue
        end
        c = get_citation(pkg, zenodo=zenodo)
        if !isnothing(c)
            push!(pkg_citations, pkg.name=>c)
        end
    end

    return pkg_citations
end

function bibliography(pkg_citations)
    merge(values(pkg_citations)...)
end

function cited_packages(pkg_citations)
    keys(pkg_citations)
end

function export_citations(filename, pkg_citations)
    citations = bibliography(pkg_citations)
    if isfile(filename)
        @warn "Overwriting $filename"
    end
    if isempty(citations)
        return nothing
    end
    export_bibtex(filename, citations)
    pkgs = join(cited_packages(pkg_citations), ", ", " and ")
    @info "A $filename file with the citations for $pkgs" *
    " was generated in the current working directory ($(pwd()))."
end

"""
    get_citations(; only_direct=false, filename="julia_citations.bib")

This function will create a .bib file with all the citations collected form
the CITATION.bib files corresponding to the dependecies of
the current active environment. Use `filename` to change the name of the
file. To include just the direct dependencies use `only_direct=true`.
Use `zenodo = true` to get the citations from packages without
a `Citation.bib` file, but with a Zenodo's badge.
"""
function get_citations(;only_direct=false, filename="julia_citations.bib", zenodo=false)
    pkg_citations = collect_citations(only_direct, zenodo=zenodo)

    if isempty(pkg_citations)
        @warn "No citations found in current environment"
    else
        export_citations(filename, pkg_citations)
    end

    return nothing
end

"""
    get_citation_zenodo(url::String)

This function will return an `OrderedDict` in the default to BibTeX format
from `Bibliography.jl`. The `url` argument is the link present in the
Zenodo badge.
"""
function get_citation_zenodo(url)
    isnothing(url) && return url
    header = HTTP.head(url, redirect=false).headers
    doi = last(header[findfirst(i -> isequal("Location", first(i)), header)])[17:end]
    url = joinpath("https://data.datacite.org/", doi)
    resp = HTTP.get(url, ["Accept"=>"application/x-bibtex"]; forwardheaders=true).body |> String
    bib = parse_entry(resp)
    return bib
end

"""
    get_zenodo_badge(pkg)

This function extracts the link in the Zenodo badge
present in the package's `README.md`.
"""
function get_zenodo_badge(pkg)
    readme_path = joinpath(pkg.source, "README.md")
    if isfile(readme_path)
        readme = open(f->read(f, String), readme_path);
        index_init = findlast("https://zenodo.org/badge", readme)
        if isnothing(index_init)
            urlbadge = nothing
        else
            index_init  = index_init[1]
            index_final = findfirst(')',readme[index_init:end]) - 2
            urlbadge = readme[index_init: index_init + index_final]
            if !isnothing(findfirst(".svg", urlbadge))
                @warn "Link in Zenodo badge incorrectly setup for $(pkg.name). Link should be something like `https://zenodo.org/badge/latestdoi/32700186`."
                return nothing
            end
        end
        return urlbadge
    end
    return nothing
end
