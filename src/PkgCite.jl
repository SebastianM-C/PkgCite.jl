module PkgCite

using DataStructures: getkey, values
using Base: String
export get_citations, get_tool_citation, bib_to_cff

import Pkg
using Bibliography: import_bibtex, export_bibtex, import_cff, export_cff, Entry
using DataStructures
using InteractiveUtils
using BibParser: parse_entry
using HTTP

const DEFAULT_CITE = "\\cite"

include("citations.jl")
include("tool_report.jl")
include("utils.jl")

end
