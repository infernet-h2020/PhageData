@testset "rubin2017genbio" begin
    data = PhageData.rubin2017genbio()
    @test allunique(data.sequences)
end