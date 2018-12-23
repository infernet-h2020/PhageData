using Test, PhageData, PhageBase


@testset "rubin2017genbio" begin
    data = PhageData.rubin2017genbio()
    @test allunique(data.sequences)
end

@testset "boyer2016pnas" begin
    data = PhageData.boyer2016pnas_pvp()
    @test allunique(data.sequences)
end
