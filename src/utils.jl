function get_julia_bib()
    import_bibtex(joinpath(@__DIR__, "julia.bib"))
end

function add_texttt(pkg_name)
    "\\texttt{" * pkg_name * "}"
end
