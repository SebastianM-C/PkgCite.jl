using Cite
using Cite: collect_citations, bibliography, cited_packages
using Bibliography
using Test
using Pkg

@testset "Cite.jl" begin
    @testset "Empty env" begin
        @test_logs (:warn, "No citations found in current environment") get_citations()
    end

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

    @testset "Cite sentence" begin
        io = IOBuffer()
        get_tool_citation(io)
        seekstart(io)
        str = read(io, String)

        @test str == "This work was done in \\cite[Julia v$VERSION]{Julia-2017} "*
        "and made use of the following packages: "*
        "LabelledArrays.jl\\cite[LabelledArrays]{DifferentialEquations.jl-2017}, "*
        "QuadGK.jl\\cite[QuadGK]{quadgk}, Symbolics.jl\\cite[Symbolics]{gowda2021high}, "*
        "RecursiveArrayTools.jl\\cite[RecursiveArrayTools]{DifferentialEquations.jl-2017}, "*
        "ArrayInterface.jl\\cite[ArrayInterface]{DifferentialEquations.jl-2017} and "*
        "AbstractAlgebra.jl\\cite[AbstractAlgebra]{AbstractAlgebra.jl-2017}.\n"

        io = IOBuffer()
        get_tool_citation(io, jl=false)
        seekstart(io)
        str = read(io, String)

        @test str == "This work was done in \\cite[Julia v$VERSION]{Julia-2017} "*
        "and made use of the following packages: "*
        "LabelledArrays\\cite[LabelledArrays]{DifferentialEquations.jl-2017}, "*
        "QuadGK\\cite[QuadGK]{quadgk}, Symbolics\\cite[Symbolics]{gowda2021high}, "*
        "RecursiveArrayTools\\cite[RecursiveArrayTools]{DifferentialEquations.jl-2017}, "*
        "ArrayInterface\\cite[ArrayInterface]{DifferentialEquations.jl-2017} and "*
        "AbstractAlgebra\\cite[AbstractAlgebra]{AbstractAlgebra.jl-2017}.\n"
    end

end
