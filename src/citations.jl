function citation_path(pkg)
    # Check for CITATION.cff first (preferred format)
    cff_path = joinpath(pkg.source, "CITATION.cff")
    if isfile(cff_path)
        return (cff_path, :cff)
    end

    # Fall back to CITATION.bib
    bib_path = joinpath(pkg.source, "CITATION.bib")
    if isfile(bib_path)
        return (bib_path, :bib)
    end

    return nothing
end


# Added `badge` flag to avoid breaking current tests
function get_citation(pkg; badge=false)
    citation_info = citation_path(pkg)
    if badge == false
        urlbadge = nothing
    else
        urlbadge = get_badge(pkg)
    end
    if !isnothing(citation_info)
        citation_file, format = citation_info
        @debug "Reading $(format == :cff ? "CITATION.cff" : "CITATION.bib") for $(pkg.name)"
        try
            if format == :cff
                # Import CFF and convert to internal format
                entry = import_cff(citation_file)
                # CFF import returns a single Entry, wrap it in an OrderedDict
                bib = DataStructures.OrderedDict{String, Entry}()
                # Use the package name as the citation key if no key exists
                key = haskey(entry, :id) ? entry.id : pkg.name
                bib[key] = entry
                return bib
            else
                bib = import_bibtex(citation_file, check=:warn)
                if isempty(bib)
                    @warn "The CITATION.bib file for $(pkg.name) is empty."
                end
                return bib
            end
        catch e
            format_name = format == :cff ? "CITATION.cff" : "CITATION.bib"
            @warn "There was an error reading the $format_name file for $(pkg.name)" exception=e
        end
    elseif !isnothing(urlbadge)
        get_citation_badge(urlbadge)
    end
end

"""
    collect_citations(only_direct::Bool; badge=false)

Collect the citations from all the dependencies in the current environment.
Use `badge = true` to get the citations from packages without
a `Citation.bib` file, but with a DOI badge.
"""
function collect_citations(only_direct::Bool; badge=false)
    @debug "Generating citation report for the current environment"
    deps = Pkg.dependencies()
    pkg_citations = Dict{String, DataStructures.OrderedDict{String,Entry}}()
    for pkg in values(deps)
        if only_direct && !pkg.is_direct_dep
            continue
        end
        c = get_citation(pkg, badge=badge)
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
    get_citations(; only_direct=false, filename="julia_citations.bib")

This function will create a .bib file with all the citations collected form
the CITATION.bib files corresponding to the dependecies of
the current active environment. Use `filename` to change the name of the
file. To include just the direct dependencies use `only_direct=true`.
Use `badge = true` to get the citations from packages without
a `Citation.bib` file, but with a DOI badge.
"""
function get_citations(;only_direct=false, filename="julia_citations.bib", badge=false)
    pkg_citations = collect_citations(only_direct, badge=badge)

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

"""
    bib_to_cff(bib_file::String, cff_file::String="CITATION.cff")

Convert a BibTeX citation file to CFF (Citation File Format).
Reads the first entry from the BibTeX file and exports it as CFF.

# Arguments
- `bib_file::String`: Path to the input CITATION.bib file
- `cff_file::String`: Path to the output CITATION.cff file (default: "CITATION.cff")

# Example
```julia
bib_to_cff("CITATION.bib", "CITATION.cff")
```
"""
function bib_to_cff(bib_file::String, cff_file::String="CITATION.cff")
    if !isfile(bib_file)
        error("BibTeX file not found: $bib_file")
    end

    # Import the BibTeX file
    bib = import_bibtex(bib_file, check=:warn)

    if isempty(bib)
        error("The BibTeX file is empty or could not be parsed")
    end

    # Get the first entry (most BibTeX citation files have a single main entry)
    entry = first(values(bib))

    # Export to CFF format
    try
        export_cff(entry; destination=cff_file)
        @info "Successfully converted $bib_file to $cff_file"
    catch e
        @error "Failed to export to CFF format" exception=e
        rethrow(e)
    end

    return nothing
end
