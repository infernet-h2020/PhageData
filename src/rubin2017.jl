"reads .fastq.prot.counts file into a DataFrame"
readwrap(path::String) = CSV.read(DATADIR * path * ".fastq.prot.counts"; delim='\t', header=["seq", "N"], types=[String, Int])


"""
    rubin2017()

Returns dataset from Rubin et al 2017 Genome Biology paper.
"""
function rubin2017()
    df00 = readwrap("/rubin2017genbio/SRR4293387")  # initial library
    df13 = readwrap("/rubin2017genbio/SRR4293388")  # replicate 1, round 3
    df16 = readwrap("/rubin2017genbio/SRR4293389")  # replicate 1, round 6
    df23 = readwrap("/rubin2017genbio/SRR4293390")  # replicate 2, round 3
    df26 = readwrap("/rubin2017genbio/SRR4293391")  # replicate 2, round 6
    df33 = readwrap("/rubin2017genbio/SRR4293392")  # replicate 3, round 3
    df36 = readwrap("/rubin2017genbio/SRR4293393")  # replicate 3, round 6

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