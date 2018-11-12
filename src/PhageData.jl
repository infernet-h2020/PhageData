module PhageData

using PhageBase, CSV, DataFrames

export clean, clean!, rmzero


"base directory containing data"
DATADIR = "/home/cossio/work/PhageDisplayInference/data"

include("base.jl")
include("rubin2017.jl")

end # module
