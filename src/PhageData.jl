module PhageData

using PhageBase, CSV, DataFrames


#= data location =#
if haskey(ENV, "PHAGEDATAPATH")
    const DATAPATH = ENV["PHAGEDATAPATH"]
else
    error("Please set PHAGEDATAPATH environment variable (or ENV[\"PHAGEDATAPATH\"]) with a directory to place DMS data")
end
run(`mkdir -p $DATAPATH`)


# import because we don't want conflicts with our Sequence type
import BioSequences, BioAlignments


export clean, clean!, rmzero

export boyer2016pnas_pvp, boyer2016pnas_dna,
       rubin2017genbio


include("base.jl")
include("rubin2017genbio.jl")
include("boyer2016pnas.jl")
include("fowler2010nmeth.jl")

end # module
