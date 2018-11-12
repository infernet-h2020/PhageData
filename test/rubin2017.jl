@testset "rubin2017" begin
    data = PhageData.rubin2017()
    @test allunique(data.sequences)
end