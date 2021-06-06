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

function start_sentence(n; cite_commands=Dict{String,String}())
    bib = get_julia_bib()
    julia = cite_package("Julia v$VERSION", bib; cite_commands)
    if n == 1
        "This work was done in $julia and made use of the "
    else
        "This work was done in $julia and made use of the following packages: "
    end
end

function sentence_ending(n)
    if n == 1
        " package."
    else
        "."
    end
end

function get_tool_citation(io::IO=stdout;
    jl = true,
    texttt = false,
    cite_commands=Dict{String,String}(),
    filename="julia_citations.bib")

    pkg_citations = collect_citations()
    pkgs = keys(pkg_citations)
    n = length(pkgs)

    start = start_sentence(n; cite_commands)

    citations = String[]
    for pkg in pkgs
        pkg_name = jl ? pkg * ".jl" : pkg
        pkg_name = texttt ? add_texttt(pkg_name) : pkg_name
        c = pkg_name * cite_package(pkg, pkg_citations[pkg]; cite_commands)
        push!(citations, c)
    end

    ending = sentence_ending(n)

    cite_sentence = start * join(citations, ", ", " and ") * ending
    try
        clipboard(cite_sentence)
        @info "The following sentence was copied to your clipboard:"
        println(io, cite_sentence)
    catch
        @error e
    end

    julia_bib = get_julia_bib()
    all_citations = merge!(Dict("Julia"=>julia_bib), pkg_citations)
    export_citations(filename, all_citations)
end
