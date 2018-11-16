import CSV, BioSequences, DataFrames


const boyer2016pnas_dir = string(@__DIR__, "/../data/boyer2016pnas")


"""
    boyer2016pnas_pvp()

Returns PVP dataset from Boyer et al 2016 PNAS paper.
If the dataset has not been downloaded, it downloads the 
original data (this can take a while).
"""
function boyer2016pnas_pvp()
    #= if the dataset is not available,
    download and/or process it =#
    if !boyer2016pnas_downloaded()
        boyer2016pnas_download()
    end

    #= load dataset into Julia =#
    pvp = read_three_rounds_counts_PVP()
    seqs = Sequence{21,4}.(sort(unique(s for c in pvp for s in keys(c))))
    S = length(seqs); V = 1; T = length(pvp);
    N = [get(pvp[t], seqs[s].s, 0.) for s=1:S, v=1:V, t=1:T]
    Dataset(seqs, N)
end



"""
    boyer2016pnas_dna()

Returns DNA dataset from Boyer et al 2016 PNAS paper.
If the dataset has not been downloaded, it downloads the 
original data (this can take a while).
"""
function boyer2016pnas_dna()
    #= if the dataset is not available,
    download and/or process it =#
    if !boyer2016pnas_downloaded()
        boyer2016pnas_download()
    end

    #= load dataset into Julia =#
    dna = read_three_rounds_counts_DNA()
    seqs = Sequence{21,4}.(sort(unique(s for c in dna for s in keys(c))))
    S = length(seqs); V = 1; T = length(dna);
    N = [get(dna[t], seqs[s].s, 0.) for s=1:S, v=1:V, t=1:T]
    Dataset(seqs, N)
end


"Download the Boyer 2016 PNAS paper dataset"
function boyer2016pnas_download()
    run(`mkdir -p $boyer2016pnas_dir`)
    for i = 2 : 19
        dd = lpad(i, 2, '0')
        @info "downloading pnas.1517813113.sd$dd.rtf"
        download("http://www.pnas.org/highwire/filestream/621929/field_highwire_adjunct_files/$i/pnas.1517813113.sd$dd.rtf",
                 "$boyer2016pnas_dir/pnas.1517813113.sd$dd.rtf")
        @info "converting to plain text"
        rtf2txt("$boyer2016pnas_dir/pnas.1517813113.sd$dd")
    end
    write(boyer2016pnas_dir * "/downloaded.txt", "Download complete")
    @info "Boyer 2016 PNAS dataset download complete"
end


"""
    urtf(file)

Convert file.rtf to file.txt. Pass file without the .rtf extension.
"""
function rtf2txt(file::String)
    unrtf = string(@__DIR__, "/../deps/unrtf-0.21.9-build/bin/unrtf")
    run(pipeline(`$unrtf --text $file.rtf`, `grep -v "^-"`, stdout="$file.txt"))
    nothing
end


"Cleans the Boyer 2016 PNAS data directory"
function boyer2016pnas_clean()
    for f in readdir(boyer2016pnas_dir)
        rm(boyer2016pnas_dir * "/" * f)
    end
end


"returns true if the Boyer et al 2016 PNAS data has been downloaded"
boyer2016pnas_downloaded() = isfile(boyer2016pnas_dir * "/downloaded.txt")


function read_three_rounds_counts_PVP()
    F3_PVP_round_1_PATH = boyer2016pnas_dir * "/pnas.1517813113.sd05.txt"
    F3_PVP_round_2_PATH = boyer2016pnas_dir * "/pnas.1517813113.sd06.txt"
    F3_PVP_round_3_PATH = boyer2016pnas_dir * "/pnas.1517813113.sd07.txt"

    round1df = readdf(F3_PVP_round_1_PATH);
    round2df = readdf(F3_PVP_round_2_PATH);
    round3df = readdf(F3_PVP_round_3_PATH);
    counts = [counts_aa_seq(round1df), 
              counts_aa_seq(round2df), 
              counts_aa_seq(round3df)]

    return counts
end


function read_three_rounds_counts_DNA()
    F3_DNA_round_1_PATH = boyer2016pnas_dir * "/pnas.1517813113.sd02.txt"
    F3_DNA_round_2_PATH = boyer2016pnas_dir * "/pnas.1517813113.sd03.txt"
    F3_DNA_round_3_PATH = boyer2016pnas_dir * "/pnas.1517813113.sd04.txt"
    
    round1df = readdf(F3_DNA_round_1_PATH);
    round2df = readdf(F3_DNA_round_2_PATH);
    round3df = readdf(F3_DNA_round_3_PATH);
    counts = [counts_aa_seq(round1df), 
              counts_aa_seq(round2df), 
              counts_aa_seq(round3df)]
    return counts
end



function readdf(path::String)
    df = readdata(path)
    DataFrames.rename!(df, :counts => :nt_counts)
    df[:aa_seq] = String.(dna2prot.(df[:nt_seq]))
    df[:aa_iseq] = [([aa2int[c] for c in sequence]...,) for sequence in df[:aa_seq]]
    counts = counts_aa_seq(df)
    df[:aa_counts] = [counts[s] for s in df[:aa_iseq]]
    return df
end


readdata(file) = CSV.read(file; delim=';', types=[String, String, Int], comment="#");
dna2prot(seq::String) = BioSequences.translate(BioSequences.RNASequence(
                                               BioSequences.DNASequence(seq));
                                               code = BioSequences.bacterial_plastid_genetic_code)

function counts_aa_seq(df)
    L = length(first(df[:aa_iseq]))
    counts = Dict{NTuple{L,Int},Float64}()
    for (s, n) in zip(df[:aa_iseq], df[:nt_counts])
        @assert length(s) == L
        counts[s] = get(counts, s, 0.) + float(n)
    end
    return counts
end
