module PhageData

using PhageBase, CSV, DataFrames, Distributed

# import because we don't want conflicts with our Sequence type
import BioSequences, BioAlignments


export clean, clean!, rmzero
export boyer2016pnas_pvp, boyer2016pnas_dna


"base directory containing data"
DATADIR = "/home/cossio/work/PhageDisplayInference/data"

include("base.jl")
include("clean.jl")
include("rubin2017genbio.jl")
include("boyer2016pnas.jl")

end # module
