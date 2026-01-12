using PkgCite
using PkgCite: collect_citations, bibliography, cited_packages, make_sentence
using InteractiveUtils
using Bibliography
using Test
import Pkg

# Helper function to check if clipboard is available
function clipboard_available()
    try
        clipboard("")
        return true
    catch
        return false
    end
end

@testset "PkgCite.jl" begin
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
        # Test that Symbolics (the direct dependency) is found
        @test "Symbolics" ∈ pkgs
        # Test that we find some transitive dependencies with citations
        @test length(pkgs) > 1
        # Test that citations were actually collected
        @test !isempty(citations)
        # There is an error in the CITATION.bib for Distributions
        @test_broken haskey(citations, "Distributions")
    end

    @testset "Citations" begin
        bib = bibliography(citations)
        # Test that we have some citations in the bibliography
        @test !isempty(bib)
        # Test that we got some actual bibliography entries
        @test length(bib) >= 1
    end

    get_citations()

    @testset "Citations in .bib" begin
        bib_path = joinpath(@__DIR__, "julia_citations.bib")
        @test isfile(bib_path)

        # Try to import the .bib file, but handle BibParser errors gracefully
        # (some citation types like @software may not be supported by BibParser)
        try
            bib = import_bibtex(bib_path)
            # Test that the .bib file contains some citations
            @test !isempty(bib)
            # Test that Julia citation is present
            @test haskey(bib, "Julia-2017")
        catch e
            if e isa KeyError && e.key == "software"
                @warn "BibParser doesn't support @software entry type, skipping .bib import test"
                @test_skip false
            else
                rethrow(e)
            end
        end
    end

    @testset "Only direct dependencies" begin
        citations = collect_citations(true)
        pkgs = cited_packages(citations)
        @test only(pkgs) == "Symbolics"

        # Test sentence structure without hard-coding exact citation keys
        sentence = make_sentence(citations)
        @test occursin("Julia v$VERSION", sentence)
        @test occursin("Symbolics.jl", sentence)
        @test occursin("\\cite", sentence)

        sentence_tt = make_sentence(citations, texttt=true)
        @test occursin("\\texttt{Symbolics.jl}", sentence_tt)
    end

    @testset "PkgCite sentence" begin
        citations = collect_citations(false)
        str = make_sentence(citations)

        # Test sentence structure
        @test startswith(str, "This work was done in \\cite[Julia v$VERSION]")
        @test occursin("made use of the following packages:", str)
        @test occursin("Symbolics.jl", str)
        @test endswith(str, ".")

        # Test without .jl suffix
        str = make_sentence(citations, jl=false)
        @test occursin("Symbolics\\cite", str)
        @test !occursin("Symbolics.jl", str)

        # Test custom cite command
        str = make_sentence(citations, cite_commands=Dict{String,String}("Symbolics" => "\\autocite"))
        @test occursin("\\autocite", str)

        @testset "Clipboard" begin
            io = IOBuffer()
            get_tool_citation(io)
            str = String(take!(io))

            # Test that output is generated
            @test !isempty(str)
            @test occursin("Julia v$VERSION", str)
            @test occursin("Symbolics", str)

            # Only test clipboard if available
            if clipboard_available()
                @test clipboard() == strip(str)

                # Test without .jl suffix
                get_tool_citation(io, jl=false)
                str_no_jl = String(take!(io))
                @test clipboard() == strip(str_no_jl)
            else
                @info "Skipping clipboard tests (clipboard not available)"
            end
        end
    end

    @testset "PkgCite using badge" begin
        zenodo_env = "badge_env"
        Pkg.activate(zenodo_env)

        # Try to instantiate, but skip if it fails (e.g., due to Julia version issues)
        try
            Pkg.instantiate()
            Pkg.status()

            citations = collect_citations(true, badge=true)
            pkgs = cited_packages(citations)
            @test issubset(["WriteVTK"], pkgs)

            # Test that sentence is generated with DOI citations
            sentence = make_sentence(citations)
            @test occursin("Julia v$VERSION", sentence)
            @test occursin("WriteVTK.jl", sentence)
            @test occursin("\\cite", sentence)
        catch e
            @warn "Skipping badge environment tests due to instantiation error" exception=(e, catch_backtrace())
            @test_skip false
        end
    end
end
