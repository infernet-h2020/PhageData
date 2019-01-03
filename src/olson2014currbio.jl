const olson2014currbio_dir = DATAPATH * "/olson2014currbio"

"""
    olson2014currbio_gb1()

Returns GB1 dataset from Olson et al 2014 Current Biology paper.
If the dataset has not been downloaded, it downloads the
original data (this can take a while).
"""
function olson2014currbio_gb1()
    #= if the dataset is not available,
    download and/or process it =#
    if !olson2014currbio_downloaded()
        olson2014currbio_download()
    end

    df = DataFrame(load(olson2014currbio_dir * "/mmc2.xlsx", "DoubleSub.xls"))

    pos1 = convert.(Int, df[2:end,:x1])
    wt1 = df[2:end, 1]
    mut1 = df[2:end,:x2]
    pos2 = convert.(Int, df[2:end,:x4])
    wt2 = df[2:end, :x3]
    mut2 = df[2:end,:x5];
    input_count_double = convert.(Int, df[2:end,:x6])
    sel_count_double = convert.(Int, df[2:end,:x7])

    @assert length(pos1) == length(pos2) == length(wt1) == length(wt2) == length(mut1) == length(mut2)

    pos = convert.(Int, skipmissing(df[2:end, :x12]))
    wt = String.(skipmissing(df[2:end, 13]));
    mut = String.(skipmissing(df[2:end, :x13]));
    input_count = convert.(Int, skipmissing(df[2:end, :x14]))
    sel_count = convert.(Int, skipmissing(df[2:end, :x15]))

    @assert length(pos) == length(wt) == length(mut) == length(input_count) == length(sel_count)

    wtdict = Dict(pos .=> wt)
    wtseqstr = string((wtdict[p] for p = 2:56)...)
    wtseq = PhageData.str2seq(wtseqstr)

    A = 21; L = length(wtseq)

    single_muts = mapreduce(vcat, 1 : length(pos)) do s
        mutseq = collect(wtseq)
        mutseq[pos[s] - 1] = PhageData.aa2int[first(mut[s])]
        Sequence{A,L}(mutseq)
    end

    double_muts = mapreduce(vcat, 1 : length(pos1)) do s
        mutseq = collect(wtseq)
        mutseq[pos1[s] - 1] = PhageData.aa2int[first(mut1[s])]
        mutseq[pos2[s] - 1] = PhageData.aa2int[first(mut2[s])]
        Sequence{A,L}(mutseq)
    end

    sequences = vcat(single_muts, double_muts)

    counts = zeros(Int, length(sequences), 1, 2);
    counts[:,1,1] .= [input_count; input_count_double]
    counts[:,1,2] .= [sel_count; sel_count_double];

    return Dataset(sequences, counts)
end

"Download the GB1 dataset from Olson et al 2014 Current Biology paper"
function olson2014currbio_download()
    run(`mkdir -p $olson2014currbio_dir`)
    @info "downloading Olson et al 2014 Current Biology dataset"
    url = "https://www.cell.com/cms/10.1016/j.cub.2014.09.072/attachment/3a36211d-bddd-43e3-bf42-a6721f93a18b/mmc2.xlsx"
    run(`wget -o $olson2014currbio_dir/mmc2.xlsx $url`)
    write(olson2014currbio_dir * "/downloaded.txt", "Download complete")
    @info "Olson et al 2014 Current Biology dataset download complete"
    return nothing
end

"Cleans the Olson et al 2014 Current Biology data directory"
function olson2014currbio_clean()
    for f in readdir(olson2014currbio_dir)
        rm(olson2014currbio_dir * "/" * f)
    end
end

"returns true if the Olson et al 2014 Current Biology data has been downloaded"
olson2014currbio_downloaded() = isfile(olson2014currbio_dir * "/downloaded.txt")
