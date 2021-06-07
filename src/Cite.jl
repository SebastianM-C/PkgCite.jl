module Cite

using Pkg: include
using DataStructures: getkey, values
using Base: String
export get_citations, get_tool_citation

import Pkg
using Bibliography: import_bibtex, export_bibtex, Entry
using DataStructures
using InteractiveUtils

const DEFAULT_CITE = "\\cite"

include("citations.jl")
include("tool_report.jl")
include("utils.jl")

end
