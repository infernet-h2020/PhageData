const fowler2010nmeth_dir = DATAPATH * "/fowler2010nmeth"


"""
    fowler2010nmeth()

Returns dataset from Fowler et al 2010 Nat. Meth. paper.
If the dataset has not been downloaded, it downloads the
original data and processes it (this can take a while).
"""
function fowler2010nmeth()
    #= if the dataset is not available,
    download and/or process it =#
    if !fowler2010nmeth_downloaded()
        fowler2010nmeth_download()
    end

    #= load dataset into Julia =#

    df0 = readcounts(fowler2010nmeth_dir * "/SRR058872.counts")  # initial library
    df3 = readcounts(fowler2010nmeth_dir * "/SRR058873.counts")  # round 3
    df6 = readcounts(fowler2010nmeth_dir * "/SRR058874.counts")  # round 6

    sequences_str = union(df0[:seq], df3[:seq], df6[:seq])
    sequences = str2seq.(sequences_str)

    S = length(sequences)
    V = 1
    T = 3

    # fast linear index of a sequence
    seqidx = Dict(seq => i for (i, seq) in enumerate(sequences_str))

    N = zeros(Int, S, V, T)

    for row in eachrow(df0)
        s = seqidx[row[:seq]]
        # the initial pool reads are shared between replicates
        N[s,1,1] = N[s,2,1] = N[s,3,1] = row[:counts]
    end

    for row in eachrow(df3)
        s = seqidx[row[:seq]]
        N[s,1,2] = row[:counts]
    end

    for row in eachrow(df6)
        s = seqidx[row[:seq]]
        N[s,1,3] = row[:counts]
    end

    Dataset(sequences, N)
end


"returns true if the Fowler et al 2010 Nature Methods data has been downloaded"
fowler2010nmeth_downloaded() = isfile(fowler2010nmeth_dir * "/downloaded.txt")


"""
    fowler2010nmeth_download()

Download the Fowler et al 2010 Nature Methods dataset.
(This takes a while).
"""
function fowler2010nmeth_download()
    run(`mkdir -p $fowler2010nmeth_dir`)
    @info "Downloading Fowler 2010 Nature Methods dataset to $fowler2010nmeth_dir (this only happens the first time you load this dataset)"
    fastqdump = string(@__DIR__, "/../deps/sratoolkit.2.9.2-ubuntu64/bin/fastq-dump")

    "alignment score model used by Fowler2010"
    fowler_score_model = BioAlignments.AffineGapScoreModel(gap_open=-3, gap_extend=-1, mismatch=-1, match=2);

    for id = 2:4
        # TODO: consider doing this loop parallel
        srr = "SRR05887" * string(id)

        @info "Downloading $srr to $fowler2010nmeth_dir"
        run(`$fastqdump -v -O $fowler2010nmeth_dir $srr`)

        @info "Converting to protein sequences"

        open("$fowler2010nmeth_dir/$srr.fastq", "r") do stream
            fastq = BioSequences.FASTQ.Reader(stream; fill_ambiguous = nothing)
            open("$fowler2010nmeth_dir/$srr.prot", "w") do out
                for (iter, r) in enumerate(fastq)
                    # quality scores
                    q = BioSequences.FASTQ.quality(r, :illumina18)
                    @assert length(q) == 152    # length of read

                    #= the read consists of two mirroring sequences =#
                    qf, qr = q[1:75], reverse(q[77:end-1])
                    @assert length(qf) == length(qr) == 75

                    # discard if low mean quality
                    mean(qf) ≥ 20 && mean(qr) ≥ 20 || continue

                    s = BioSequences.FASTQ.sequence(r)
                    @assert length(s) == 152

                    sf, sr = s[1:75], BioSequences.reverse_complement(s[77:end-1])
                    @assert length(sf) == length(sr) == 75

                    #= align sequence and its mirror, using Fowler2010 score model.
                    Ignore if there are gaps =#
                    alignment = BioAlignments.alignment(BioAlignments.pairalign(BioAlignments.GlobalAlignment(), sf, sr, fowler_score_model))
                    gaps = BioAlignments.count_insertions(alignment) + BioAlignments.count_deletions(alignment)
                    gaps > 0 && continue

                    #= if two positions in the mirror sequence don't match,
                    we will keep the one with highest quality. If both positions
                    have the same quality, ignore. =#
                    all((collect(sf) .== collect(sr)) .| (qf .≠ qr)) || continue
                    @assert all((collect(sf) .== collect(sr)) .| (qf .≠ qr))
                    seq = [q1 ≥ q2 ? n1 : n2 for (n1,n2,q1,q2) in zip(sf,sr,qf,qr)]
                    @assert length(seq) == 75

                    # convert to protein seq
                    protseq = BioSequences.translate(BioSequences.RNASequence(BioSequences.DNASequence(string(join(seq)))))
                    write(out, string(join(protseq)) * "\n")
                end
            end
        end

        @info "Unique protein counts ..."

        counts = Dict{String,Int}()
        for line in eachline("$fowler2010nmeth_dir/$srr.prot")
            seq = strip(line)
            counts[seq] = get(counts, seq, 0) + 1
        end
        open("$fowler2010nmeth_dir/$srr.counts", "w") do out
            for (seq, n) in counts
                write(out, seq * "\t$n\n")
            end
        end
    end

    write(fowler2010nmeth_dir * "/downloaded.txt", "Download complete")
    @info "Fowler 2010 Nature Methods dataset download complete"
end


"""
    fowler2010nmeth_clean()

Cleans the Fowler 2010 Nature Methods data directory
"""
function fowler2010nmeth_clean()
    for f in readdir(fowler2010nmeth_dir)
        rm(fowler2010nmeth_dir * "/" * f)
    end
end
