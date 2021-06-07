# Cite

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://SebastianM-C.github.io/Cite.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SebastianM-C.github.io/Cite.jl/dev)
[![Build Status](https://github.com/SebastianM-C/Cite.jl/workflows/CI/badge.svg)](https://github.com/SebastianM-C/Cite.jl/actions)
[![Coverage](https://codecov.io/gh/SebastianM-C/Cite.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SebastianM-C/Cite.jl)

## Installation

Right now this package is not yet registered. If you want to try it, use
```
]add https://github.com/SebastianM-C/Cite.jl
```

## Usage

To get all the dependencies in the current environment, use
```julia
using Cite

# Be sure to be in the appropriate environment

get_tool_citation()
```
which will print a sentence with the citations for all the packages used in the current
environment and will automatically copy it to the clipboard.
It will also create a `julia_citations.bib` file with all the citations collected form
the CITATION.bib files corresponding to the dependecies of the current active environment.
