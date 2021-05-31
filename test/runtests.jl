using Cite
using Cite: collect_citations
using Test
using Pkg

@testset "Cite.jl" begin
    test_env = "test_env"
    Pkg.activate(test_env)

    citations = collect_citations()
    @show citations
    @test haskey(citations, "DifferentialEquations.jl-2017")
    @test haskey(citations, "AbstractAlgebra.jl-2017")
    @test haskey(citations, "quadgk")
    @test haskey(citations, "gowda2021high")

    get_citations()
    @test isfile(joinpath(@__DIR__, "julia_citations.bib"))
end
