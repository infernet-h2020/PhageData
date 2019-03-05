const rubin2017genbio_dir = DATAPATH * "/rubin2017genbio"

"""
    rubin2017genbio_c1()

Returns dataset from Rubin et al 2017 Genome Biology paper.
If the dataset has not been downloaded, it downloads the
original data and processes it (this can take a while).
"""
function rubin2017genbio_c1()
    #= if the dataset is not available, acquire it =#
    if !rubin2017genbio_downloaded()
        rubin2017genbio_download()
    end
    if !rubin2017genbio_processed()
        rubin2017genbio_process()
    end

    #= load dataset into Julia =#

    df00 = readcounts(rubin2017genbio_dir * "/SRR4293387.counts")  # initial library
    df13 = readcounts(rubin2017genbio_dir * "/SRR4293388.counts")  # replicate 1, round 3
    df16 = readcounts(rubin2017genbio_dir * "/SRR4293389.counts")  # replicate 1, round 6
    df23 = readcounts(rubin2017genbio_dir * "/SRR4293390.counts")  # replicate 2, round 3
    df26 = readcounts(rubin2017genbio_dir * "/SRR4293391.counts")  # replicate 2, round 6
    df33 = readcounts(rubin2017genbio_dir * "/SRR4293392.counts")  # replicate 3, round 3
    df36 = readcounts(rubin2017genbio_dir * "/SRR4293393.counts")  # replicate 3, round 6

    sequences_str = union(df00[:seq], df13[:seq], df16[:seq], df23[:seq], df26[:seq], df33[:seq], df36[:seq])
    sequences = str2seq.(sequences_str)

    S = length(sequences)
    V = 3
    T = 3

    # linear index of each sequence
    seqidx = Dict(seq => i for (i,seq) in enumerate(sequences_str))

    N = zeros(Int, S, V, T)

    # the initial pool reads are shared between replicates
    for row in eachrow(df00)
        s = seqidx[row[:seq]]
        N[s,1,1] = N[s,2,1] = N[s,3,1] = row[:counts]
    end

    for row in eachrow(df13)
        s = seqidx[row[:seq]]
        N[s,1,2] = row[:counts]
    end

    for row in eachrow(df16)
        s = seqidx[row[:seq]]
        N[s,1,3] = row[:counts]
    end

    for row in eachrow(df23)
        s = seqidx[row[:seq]]
        N[s,2,2] = row[:counts]
    end

    for row in eachrow(df26)
        s = seqidx[row[:seq]]
        N[s,2,3] = row[:counts]
    end

    for row in eachrow(df33)
        s = seqidx[row[:seq]]
        N[s,3,2] = row[:counts]
    end

    for row in eachrow(df36)
        s = seqidx[row[:seq]]
        N[s,3,3] = row[:counts]
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

    fastqdump = if Sys.islinux()
        string(@__DIR__, "/../deps/sratoolkit.2.9.2-ubuntu64/bin/fastq-dump")
    elseif Sys.isapple()
        string(@__DIR__, "/../deps/sratoolkit.2.9.4-1-mac64/bin/fastq-dump")
    end
    for id = 87 : 93
        # TODO: consider doing this loop parallel
        srr = "SRR42933" * string(id)

        @info "Downloading $srr to $rubin2017genbio_dir"
        run(`$fastqdump -v -O $rubin2017genbio_dir $srr`)
    end
    write(rubin2017genbio_dir * "/downloaded.txt", "Download complete")
    @info "Rubin 2017 dataset download complete"
end

"""
    rubin2017genbio_process()

Process the Rubin 2017 Gen. Bio. paper dataset.
"""
function rubin2017genbio_process()
    "alignment score model used by Fowler2010"
    fowler_score_model = BioAlignments.AffineGapScoreModel(gap_open=-3, gap_extend=-1, mismatch=-1, match=2);
    for id = 87 : 93
        srr = "SRR42933" * string(id)
        @info "Converting to protein sequences"
        open("$rubin2017genbio_dir/$srr.fastq", "r") do stream
            fastq = BioSequences.FASTQ.Reader(stream; fill_ambiguous = nothing)
            open("$rubin2017genbio_dir/$srr.prot", "w") do out
                for (iter, r) in enumerate(fastq)
                    # quality scores
                    q = BioSequences.FASTQ.quality(r, :illumina18)

                    # all nucleotides have quality ≥ 20?
                    minimum(q) ≥ 20 || continue

                    s = BioSequences.FASTQ.sequence(r)
                    @assert length(q) == length(s) == 75

                    #= The 12 nucleotides (= 4 amino acids) sequence
                    fits in the forward and backward directions in the
                    75 read, plus some constant segments that we ignore. =#
                    qf, qr = q[1:12], reverse(q[51:62])
                    sf, sr = s[1:12], BioSequences.reverse_complement(s[51:62])
                    @assert length(qf) == length(qr) ==
                            length(sf) == length(sr) == 12

                    #= align sequence and its mirror, using Fowler2010 score model.
                    Ignore if there are gaps =#
                    alignment = BioAlignments.alignment(BioAlignments.pairalign(BioAlignments.GlobalAlignment(), sf, sr, fowler_score_model))
                    gaps = BioAlignments.count_insertions(alignment) + BioAlignments.count_deletions(alignment)
                    gaps > 0 && continue

                    #= if two positions in the mirror sequence don't match,
                    we will keep the one with highest quality. If both positions
                    have the same quality, ignore. =#
                    all((collect(sf) .== collect(sr)) .| (qf .≠ qr)) || continue
                    seq = [q1 ≥ q2 ? n1 : n2 for (n1,n2,q1,q2) in zip(sf,sr,qf,qr)]
                    @assert length(seq) == 12

                    # convert to protein
                    protseq = BioSequences.translate(BioSequences.RNASequence(BioSequences.DNASequence(string(join(seq)))))
                    @assert length(protseq) == 4

                    # write sequence to output file
                    write(out, string(protseq) * "\n")
                end
            end
        end

        @info "Unique protein counts ..."
        counts = Dict{String,Int}()
        for line in eachline("$rubin2017genbio_dir/$srr.prot")
            seq = strip(line)
            counts[seq] = get(counts, seq, 0) + 1
        end
        open("$rubin2017genbio_dir/$srr.counts", "w") do out
            for (seq, n) in counts
                write(out, seq * "\t$n\n")
            end
        end
    end

    write(rubin2017genbio_dir * "/processed.txt", "Processing complete")
    @info "Rubin 2017 dataset processing complete"
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
