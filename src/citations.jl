function citation_path(pkg)
    bib_path = joinpath(pkg.source, "CITATION.bib")
    if isfile(bib_path)
        bib_path
    end
end


# Added `badge` flag to avoid breaking current tests
# Added `fallback` flag to generate citations from Project.toml metadata
function get_citation(pkg; badge=false, fallback=false)
    bib_path = citation_path(pkg)
    if badge == false
        urlbadge = nothing
    else
        urlbadge = get_badge(pkg)
    end
    if !isnothing(bib_path)
        @debug "Reading CITATION.bib for $(pkg.name)"
        try
            bib = import_bibtex(bib_path, check=:warn)
            if isempty(bib)
                @warn "The CITATION.bib file for $(pkg.name) is empty."
            end

            bib
        catch e
            @warn "There was an error reading the CITATION.bib file for $(pkg.name)" exception=e
        end
    elseif !isnothing(urlbadge)
        get_citation_badge(urlbadge)
    elseif fallback
        @debug "Generating fallback citation from Project.toml for $(pkg.name)"
        generate_fallback_citation(pkg)
    end
end

"""
    collect_citations(only_direct::Bool; badge=false, fallback=false)

Collect the citations from all the dependencies in the current environment.
Use `badge = true` to get the citations from packages without
a `CITATION.bib` file, but with a DOI badge.
Use `fallback = true` to generate citations from `Project.toml` metadata
for packages without a `CITATION.bib` file or DOI badge. This can be noisy
in large environments, so it is disabled by default.
"""
function collect_citations(only_direct::Bool; badge=false, fallback=false)
    @debug "Generating citation report for the current environment"
    deps = Pkg.dependencies()
    pkg_citations = Dict{String, DataStructures.OrderedDict{String,Entry}}()
    for pkg in values(deps)
        if only_direct && !pkg.is_direct_dep
            continue
        end
        c = get_citation(pkg, badge=badge, fallback=fallback)
        if !isnothing(c)
            push!(pkg_citations, pkg.name=>c)
        end
    end

    return sort!(DataStructures.OrderedDict(pkg_citations))
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
    get_citations(; only_direct=false, filename="julia_citations.bib", badge=false, fallback=false)

This function will create a .bib file with all the citations collected from
the `CITATION.bib` files corresponding to the dependencies of
the current active environment. Use `filename` to change the name of the
file. To include just the direct dependencies use `only_direct=true`.
Use `badge = true` to get the citations from packages without
a `CITATION.bib` file, but with a DOI badge.
Use `fallback = true` to generate citations from `Project.toml` metadata
for packages without a `CITATION.bib` file or DOI badge. This can be noisy
in large environments, so it is disabled by default.
"""
function get_citations(;only_direct=false, filename="julia_citations.bib", badge=false, fallback=false)
    pkg_citations = collect_citations(only_direct, badge=badge, fallback=fallback)

    if isempty(pkg_citations)
        @warn "No citations found in current environment"
    else
        export_citations(filename, pkg_citations)
    end

    return nothing
end

"""
    get_citation_badge(url::String)

This function will return an `OrderedDict` in the default to BibTeX format
from `Bibliography.jl`. The `url` argument is the link present in the DOI badge.
"""
function get_citation_badge(urlbadge)
    isnothing(urlbadge) && return urlbadge

    index_doi = findfirst("https://doi.org/", urlbadge)
    if !isnothing(index_doi)
        # If badge link is the doi
        doi =  urlbadge[index_doi[end]+1:end]
    else
        # If link is for `lastestdoi` in Zenodo
        header = HTTP.head(urlbadge, redirect=false).headers
        # Use case-insensitive comparison for HTTP headers
        location_idx = findfirst(i -> lowercase(first(i)) == "location", header)
        if isnothing(location_idx)
            @warn "Could not find Location header for badge URL: $urlbadge"
            return nothing
        end
        location_value = last(header[location_idx])
        # Extract DOI from Location header (skip "https://doi.org/" prefix)
        doi_prefix_idx = findfirst("https://doi.org/", location_value)
        if isnothing(doi_prefix_idx)
            @warn "Location header does not contain DOI: $location_value"
            return nothing
        end
        doi = location_value[doi_prefix_idx[end]+1:end]
    end
    url = joinpath("https://data.datacite.org/", doi)
    resp = HTTP.get(url, ["Accept"=>"application/x-bibtex"]; forwardheaders=true).body |> String
    bib = parse_entry(resp)
    return bib
end

"""
    generate_fallback_citation(pkg)

Generate a citation from the package's Project.toml metadata.
Returns an OrderedDict containing a @misc BibTeX entry with package information.
This is used as a fallback when no CITATION.bib file exists.
"""
function generate_fallback_citation(pkg)
    project_path = joinpath(pkg.source, "Project.toml")
    if !isfile(project_path)
        @warn "No Project.toml found for $(pkg.name)"
        return nothing
    end

    project = TOML.parsefile(project_path)

    name = get(project, "name", pkg.name)
    version = pkg.version
    authors_raw = get(project, "authors", String[])

    # Parse authors - they may be in format "Name <email>" or just "Name"
    authors = String[]
    for author in authors_raw
        # Strip email if present
        m = match(r"^([^<]+)", author)
        if !isnothing(m)
            push!(authors, strip(m.captures[1]))
        else
            push!(authors, strip(author))
        end
    end

    # Get URL from repo or construct from package name
    url = if haskey(project, "repo")
        project["repo"]
    else
        # Try common Julia package URL patterns
        "https://github.com/JuliaPackages/$(name).jl"
    end

    # Format authors for BibTeX (Last, First and Last, First format)
    authors_str = if isempty(authors)
        "Unknown"
    else
        join(authors, " and ")
    end

    # Generate a unique citation key
    current_year = year(today())
    citation_key = "$(name)_jl_$(current_year)"

    # Create BibTeX entry
    bibtex = """
    @misc{$citation_key,
      author = {$authors_str},
      title = {$name.jl},
      year = {$current_year},
      url = {$url},
      note = {Julia package version $version}
    }
    """

    try
        bib = parse_entry(bibtex)
        return bib
    catch e
        @warn "Failed to parse generated citation for $(pkg.name)" exception=e
        return nothing
    end
end

"""
    get_badge(pkg)

This function extracts the link in the DOI badge
present in the package's `README.md`.
"""
function get_badge(pkg)
    readme_path = joinpath(pkg.source, "README.md")
    if isfile(readme_path)
        readme = open(f->read(f, String), readme_path)
        getdoi = findfirst("![DOI]", readme)
        if isnothing(getdoi)
            urlbadge = nothing
        else
            index_init = findfirst('(', readme[getdoi[end]+3:end])[1]+getdoi[end]+3
            index_final = findfirst(')',readme[index_init:end]) - 2
            urlbadge = readme[index_init: index_init + index_final]
        end
        return urlbadge
    end
    return nothing
end
