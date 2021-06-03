module Cite

using DataStructures: getkey
using Base: String
export get_citations

using Pkg
using Bibliography: import_bibtex, export_bibtex, Entry
using DataStructures
using InteractiveUtils

const DEFAULT_CITE = "\\cite"

include("citations.jl")
include("tool_report.jl")
include("utils.jl")

end
