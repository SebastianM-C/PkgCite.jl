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

function make_sentence(pkg_citations; cite_commands, jl=true, texttt=false)
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

function get_tool_citation(io::IO=stdout;
    jl = true,
    texttt = false,
    copy = true,
    cite_commands=Dict{String,String}(),
    filename="julia_citations.bib")

    pkg_citations = collect_citations()

    cite_sentence = make_sentence(pkg_citations; cite_commands, jl, texttt)

    try
        if copy
            clipboard(cite_sentence)
            @info "The following sentence was copied to your clipboard:"
            println(io, cite_sentence)
        end
    catch e
        @error e
    end

    julia_bib = get_julia_bib()
    all_citations = merge!(Dict("Julia"=>julia_bib), pkg_citations)
    export_citations(filename, all_citations)
end
