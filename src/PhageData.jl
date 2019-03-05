module PhageData

using PhageBase  # defines Dataset, Sequence
using CSV, DataFrames, ArgCheck, ExcelFiles, SHA

# import because we don't want conflicts with our Sequence type
import BioSequences, BioAlignments

export clean, clean!, rmzero
export boyer2016pnas_pvp, boyer2016pnas_dna, rubin2017genbio_c1,
       olson2014currbio_gb1


#= data location =#
if haskey(ENV, "PHAGEDATAPATH")
    const DATAPATH = ENV["PHAGEDATAPATH"]
else
    error("Please set PHAGEDATAPATH environment variable (or ENV[\"PHAGEDATAPATH\"]) with a directory to place DMS data")
end
run(`mkdir -p $DATAPATH`)

printstyled("environment variable DATAPATH set to $(ENV["PHAGEDATAPATH"])")

const sradir="sradir"

include("base.jl")
include("rubin2017genbio.jl")
include("boyer2016pnas.jl")
include("fowler2010nmeth.jl")
include("olson2014currbio.jl")
#include("glanville_vhh.jl")   # needs DatasetNoAln ..

end # module
