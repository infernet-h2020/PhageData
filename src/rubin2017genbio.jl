
const rubin2017genbio_dir = string(@__DIR__, "/../data/rubin2017genbio")


"""
    rubin2017genbio()

Returns dataset from Rubin et al 2017 Genome Biology paper.
If the dataset has not been downloaded, it downloads the
original data and processes it (this can take a while).
"""
function rubin2017genbio()
    #= if the dataset is not available,
    download and/or process it =#
    if !rubin2017genbio_downloaded()
        rubin2017genbio_download()
    end

    if !rubin2017genbio_processed()
        rubin2017genbio_process()
    end

    #= load dataset into Julia =#

    df00 = readcounts(rubin2017genbio_dir * "/SRR4293387.fastq.prot.counts")  # initial library
    df13 = readcounts(rubin2017genbio_dir * "/SRR4293388.fastq.prot.counts")  # replicate 1, round 3
    df16 = readcounts(rubin2017genbio_dir * "/SRR4293389.fastq.prot.counts")  # replicate 1, round 6
    df23 = readcounts(rubin2017genbio_dir * "/SRR4293390.fastq.prot.counts")  # replicate 2, round 3
    df26 = readcounts(rubin2017genbio_dir * "/SRR4293391.fastq.prot.counts")  # replicate 2, round 6
    df33 = readcounts(rubin2017genbio_dir * "/SRR4293392.fastq.prot.counts")  # replicate 3, round 3
    df36 = readcounts(rubin2017genbio_dir * "/SRR4293393.fastq.prot.counts")  # replicate 3, round 6

    sequences_str = union(df00[:seq], df13[:seq], df16[:seq], df23[:seq], df26[:seq], df33[:seq], df36[:seq])
    sequences = str2seq.(sequences_str)

    S = length(sequences)
    V = 3
    T = 3

    # fast linear index of a sequence
    seqidx = Dict(seq => i for (i,seq) in enumerate(sequences_str))

    N = zeros(Int, S, V, T)

    for row in eachrow(df00)
        s = seqidx[row[:seq]]
        # the initial pool reads are shared between replicates
        N[s,1,1] = N[s,2,1] = N[s,3,1] = row[:N]
    end

    for row in eachrow(df13)
        s = seqidx[row[:seq]]
        N[s,1,2] = row[:N]
    end

    for row in eachrow(df16)
        s = seqidx[row[:seq]]
        N[s,1,3] = row[:N]
    end

    for row in eachrow(df23)
        s = seqidx[row[:seq]]
        N[s,2,2] = row[:N]
    end

    for row in eachrow(df26)
        s = seqidx[row[:seq]]
        N[s,2,3] = row[:N]
    end

    for row in eachrow(df33)
        s = seqidx[row[:seq]]
        N[s,3,2] = row[:N]
    end

    for row in eachrow(df36)
        s = seqidx[row[:seq]]
        N[s,3,3] = row[:N]
    end

    Dataset(sequences, N)
end


"returns true if the Rubin2017 data has been downloaded"
rubin2017genbio_downloaded() = isfile(rubin2017genbio_dir * "/downloaded.txt")
"returns true if the Rubin2017 data has been processed"
rubin2017genbio_processed() = isfile(rubin2017genbio_dir * "/processed.txt")


"""
    rubin2017genbio_download

Download the Rubin 2017 Gen. Bio. paper dataset.
(This takes a while).
"""
function rubin2017genbio_download()
    run(`mkdir -p $rubin2017genbio_dir`)
    fastqdump = string(@__DIR__, "../deps/sratoolkit.2.9.2-ubuntu64/bin/fastq-dump")
    for id = 87 : 93
        # TODO: consider doing this loop parallel
        srr = "SRR42933" * string(id)
        @info "Downloading $srr"
        run(`$fastqdump -v $srr`)
    end
    write(rubin2017genbio_dir * "/downloaded.txt", "Download complete")
    @info "Rubin 2017 dataset download complete"
end


"""
    rubin2017genbio_process()

Process the Rubin 2017 paper dataset
"""
function rubin2017genbio_process()
    error("Not implemented") # TODO:
    write(rubin2017genbio_dir * "/processed.txt", "Processing complete")
end


"""
    rubin2017genbio_clean()

Cleans the Rubin 2017 data directory
"""
function rubin2017genbio_clean()
    for f in readdir(rubin2017genbio_dir)
        rm(rubin2017genbio_dir * "/" * f)
    end
end
