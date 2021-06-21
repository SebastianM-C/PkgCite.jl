function cite_package(name, bib; cite_commands)
    if length(bib) == 1
        key = only(keys(bib))
        cmd = get(cite_commands, name, DEFAULT_CITE)

        cmd * "[" * name * "]" * "{" * key * "}"
    else
        ks = keys(bib)
        # determine common cite command
        cmd = get(cite_commands, first(ks), DEFAULT_CITE)
        for key in ks
            cmdᵢ = get(cite_commands, name, DEFAULT_CITE)
            # all the keys must have the same command
            if cmdᵢ ≠ cmd
                # fall back to DEFAULT_CITE
                cmd = DEFAULT_CITE
            end
        end

        cmd * "[" * name * "]" * "{" * join(ks, ',') * "}"
    end
end

function start_sentence(n, cite_commands=Dict{String,String}())
    bib = get_julia_bib()
    julia = cite_package("Julia v$VERSION", bib; cite_commands)
    if n < 3
        "This work was done in $julia and made use of the "
    else
        "This work was done in $julia and made use of the following packages: "
    end
end

function sentence_ending(n)
    if n == 1
        " package."
    elseif n == 2
        " packages."
    else
        "."
    end
end

function make_sentence(pkg_citations; cite_commands=Dict{String,String}(), jl=true, texttt=false)
    pkgs = keys(pkg_citations)
    n = length(pkgs)

    start = start_sentence(n, cite_commands)
    ending = sentence_ending(n)

    citations = String[]
    for pkg in pkgs
        pkg_name = jl ? pkg * ".jl" : pkg
        pkg_name = texttt ? add_texttt(pkg_name) : pkg_name
        c = pkg_name * cite_package(pkg, pkg_citations[pkg]; cite_commands)
        push!(citations, c)
    end

    middle = n == 2 ? citations[1] * " and " * citations[2] : join(citations, ", ", " and ")

    return start * middle * ending
end

"""
    get_tool_citation(io::IO=stdout; jl = true, texttt = false, copy = true, cite_commands=Dict{String,String}(), filename="julia_citations.bib"; badge=false)

Print a sentence describing the packages used in the current environment.
If you only want to consider the direct dependencies, you can set `only_direct=true`.
The sentence is automatically copied to the clipboard(you can avoid this by using `copy=false`).
The package names have the .jl ending by default. You can ommit it with `jl=false`.
Package names can be wrapped in `texttt` by setting `texttt=true` and you can also customize
the cite command used for each package by using `cite_commands=Dict("PackageName"=>"custom_cite")`.
The filename of the .bib file can be passed via the `filename` keyword.
Use `badge = true` to get the citations from packages without
a `Citation.bib` file, but with a DOI badge.
"""
function get_tool_citation(io::IO=stdout;
    jl = true,
    texttt = false,
    copy = true,
    only_direct = false,
    cite_commands=Dict{String,String}(),
    filename="julia_citations.bib",
    badge=false)

    pkg_citations = collect_citations(only_direct, badge=badge)

    cite_sentence = make_sentence(pkg_citations; cite_commands, jl, texttt)
    println(io, cite_sentence)

    try
        if copy
            clipboard(cite_sentence)
            @info "The above sentence was copied to your clipboard."
        end
    catch e
        @error e
    end

    julia_bib = get_julia_bib()
    all_citations = merge!(Dict("Julia"=>julia_bib), pkg_citations)
    export_citations(filename, all_citations)
end
