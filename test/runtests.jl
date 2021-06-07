using Cite
using Cite: collect_citations, bibliography, cited_packages, make_sentence
using Bibliography
using Test
import Pkg

include("cite_str.jl")

@testset "Cite.jl" begin
    @testset "Empty env" begin
        @test_logs (:warn, "No citations found in current environment") get_citations()
    end

    test_env = "test_env"
    Pkg.activate(test_env)
    Pkg.instantiate()
    Pkg.status()

    citations = collect_citations(false)

    @testset "Packages" begin
        pkgs = cited_packages(citations)
        @test "LabelledArrays" ∈ pkgs
        @test "QuadGK" ∈ pkgs
        @test "Symbolics" ∈ pkgs
        @test "RecursiveArrayTools" ∈ pkgs
        @test "ArrayInterface" ∈ pkgs
        @test "AbstractAlgebra" ∈ pkgs
        # There is an error in the CITATION.bib for Distributions
        @test_broken haskey(citations, "Distributions")
    end

    @testset "Citations" begin
        bib = bibliography(citations)
        @test haskey(bib, "DifferentialEquations.jl-2017")
        @test haskey(bib, "quadgk")
        @test haskey(bib, "AbstractAlgebra.jl-2017")
        @test haskey(bib, "gowda2021high")
    end

    get_citations()

    @testset "Citations in .bib" begin
        bib_path = joinpath(@__DIR__, "julia_citations.bib")
        @test isfile(bib_path)
        bib = import_bibtex(bib_path)

        @test haskey(bib, "DifferentialEquations.jl-2017")
        @test haskey(bib, "quadgk")
        @test haskey(bib, "AbstractAlgebra.jl-2017")
        @test haskey(bib, "gowda2021high")
    end

    @testset "Only direct dependencies" begin
        citations = collect_citations(true)
        pkgs = cited_packages(citations)
        @test only(pkgs) == "Symbolics"
        @test make_sentence(citations) == CITE_STR_JL_SINGLE
        @test make_sentence(citations, texttt=true) == CITE_STR_JL_SINGLE_TT
    end

    @testset "Cite sentence" begin
        citations = collect_citations(false)
        str = make_sentence(citations)
        @test str == CITE_STR_JL

        str = make_sentence(citations, jl=false)
        @test str == CITE_STR

        str = make_sentence(citations, cite_commands=Dict{String,String}("AbstractAlgebra"=>"\\autocite"))
        @test str == CITE_STR_JL_AUTO

        @testset "Clipboard" begin
            io = IOBuffer()
            get_tool_citation(io)
            seekstart(io)
            str = read(io, String)

            @test_broken str == CITE_STR_JL*'\n'

            io = IOBuffer()
            get_tool_citation(io, jl=false)
            seekstart(io)
            str = read(io, String)

            @test_broken str == CITE_STR * '\n'
        end
    end
end
