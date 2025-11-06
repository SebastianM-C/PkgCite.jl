module PkgCite

using DataStructures: getkey, values
using Base: String
export get_citations, get_tool_citation

import Pkg
import TOML
using Bibliography: import_bibtex, export_bibtex, Entry
using Bibliography: BibInternal
using DataStructures
using InteractiveUtils
using BibParser: parse_entry
using Dates
using HTTP
using YAML

const DEFAULT_CITE = "\\cite"

include("citations.jl")
include("tool_report.jl")
include("utils.jl")

end
