using Cite
using Cite: collect_citations, bibliography, cited_packages
using Bibliography
using Test
using Pkg

@testset "Cite.jl" begin
    test_env = "test_env"
    Pkg.activate(test_env)
    Pkg.instantiate()
    Pkg.status()

    citations = collect_citations()
    @show citations
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

    get_tool_citation()
end
