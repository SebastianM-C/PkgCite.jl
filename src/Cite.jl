module Cite

using DataStructures: getkey
using Base: String
export get_citations

using Pkg
using Bibliography: import_bibtex, export_bibtex, Entry
using DataStructures
using InteractiveUtils

include("citations.jl")
include("tool_report.jl")

end
