# PkgCite

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://SebastianM-C.github.io/PkgCite.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SebastianM-C.github.io/PkgCite.jl/dev)
[![Build Status](https://github.com/SebastianM-C/PkgCite.jl/workflows/CI/badge.svg)](https://github.com/SebastianM-C/PkgCite.jl/actions)
[![Coverage](https://codecov.io/gh/SebastianM-C/PkgCite.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SebastianM-C/PkgCite.jl)

## Installation

To install this package open [the REPL](https://docs.julialang.org/en/v1/manual/getting-started/) and enter the package manager mode by pressing the <kbd>]</kbd> key and then use the following
```julia
pkg> add PkgCite
```

## Usage

To get all the dependencies in the current environment, use
```julia
using PkgCite

# Be sure to be in the appropriate environment

get_tool_citation()
```
which will print a sentence with the citations for all the packages used in the current
environment and will automatically copy it to the clipboard.
It will also create a `julia_citations.bib` file with all the citations collected form
the CITATION.bib files corresponding to the dependecies of the current active environment.

If you only need the .bib file with all the citations, use
```julia
get_citations()
```

Note: `get_citations` doesn't include the citation for the julia language itself.
