using Cite
using Test
using Pkg

@testset "Cite.jl" begin
    Pkg.activate("test_env")

    citations = get_citations()
    @test haskey(citations, "DifferentialEquations.jl-2017")
    @test haskey(citations, "AbstractAlgebra.jl-2017")
    @test haskey(citations, "quadgk")
    @test haskey(citations, "gowda2021high")
end
