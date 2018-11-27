import LibGit2
using DRBnoaln


const glanville_vhh_dir = DATAPATH * "/glanville_vhh"


"""
    glanville_vhh_cam_pro()

Returns Glanville Cam dataset, selected on ProA binding.
If the dataset has not been downloaded, it downloads the
original data (this can take a while, but is only done once).
"""
function glanville_vhh_cam_pro()
    #= if the dataset is not available,
    download and/or process it =#
    if !glanville_vhh_downloaded()
        glanville_vhh_download()
    end

    #= load dataset into Julia =#
    glanville_pre = glanville_vhh_load_CDRs("/home/cossio/work/PhageDisplayInference/data-old/Glanville/processing/VHH-Cam_PreSelect_A_md07_md04.dna.fa_CDRs.txt");
    glanville_pro = glanville_vhh_load_CDRs("/home/cossio/work/PhageDisplayInference/data-old/Glanville/processing/VHH-Cam_ProA_A_md09_md04.dna.fa_CDRs.txt");

    glanville_pre_CDR1_dict = glavnille_vhh_build_dict(glanville_pre.CDR1)
    glanville_pro_CDR1_dict = glavnille_vhh_build_dict(glanville_pro.CDR1)
    glanville_pre_CDR2_dict = glavnille_vhh_build_dict(glanville_pre.CDR2)
    glanville_pro_CDR2_dict = glavnille_vhh_build_dict(glanville_pro.CDR2)
    glanville_pre_CDR3_dict = glavnille_vhh_build_dict(glanville_pre.CDR3)
    glanville_pro_CDR3_dict = glavnille_vhh_build_dict(glanville_pro.CDR3)

    glanville_dataset_CDR1 = build_glanville_dataset(glanville_pre_CDR1_dict, glanville_pro_CDR1_dict)
    glanville_dataset_CDR2 = build_glanville_dataset(glanville_pre_CDR2_dict, glanville_pro_CDR2_dict)
    glanville_dataset_CDR3 = build_glanville_dataset(glanville_pre_CDR3_dict, glanville_pro_CDR3_dict)

    (CDR1 = glanville_dataset_CDR1,
     CDR2 = glanville_dataset_CDR2,
     CDR3 = glanville_dataset_CDR3)
end



"""
    glanville_vhh_cam_myc()

Returns Glanville Cam dataset, selected on Myc binding.
If the dataset has not been downloaded, it downloads the
original data (this can take a while, but is only done once).
"""
function glanville_vhh_cam_myc()
    #= if the dataset is not available,
    download and/or process it =#
    if !glanville_vhh_downloaded()
        glanville_vhh_download()
    end

    #= load dataset into Julia =#
    glanville_pre = glanville_vhh_load_CDRs("/home/cossio/work/PhageDisplayInference/data-old/Glanville/processing/VHH-Cam_PreSelect_A_md07_md04.dna.fa_CDRs.txt");
    glanville_myc = glanville_vhh_load_CDRs("/home/cossio/work/PhageDisplayInference/data-old/Glanville/processing/VHH-Cam_Myc_A_md11_md04.dna.fa_CDRs.txt");

    glanville_pre_CDR1_dict = glavnille_vhh_build_dict(glanville_pre.CDR1)
    glanville_myc_CDR1_dict = glavnille_vhh_build_dict(glanville_myc.CDR1)
    glanville_pre_CDR2_dict = glavnille_vhh_build_dict(glanville_pre.CDR2)
    glanville_myc_CDR2_dict = glavnille_vhh_build_dict(glanville_myc.CDR2)
    glanville_pre_CDR3_dict = glavnille_vhh_build_dict(glanville_pre.CDR3)
    glanville_myc_CDR3_dict = glavnille_vhh_build_dict(glanville_myc.CDR3)

    glanville_dataset_CDR1 = build_glanville_dataset(glanville_pre_CDR1_dict, glanville_myc_CDR1_dict)
    glanville_dataset_CDR2 = build_glanville_dataset(glanville_pre_CDR2_dict, glanville_myc_CDR2_dict)
    glanville_dataset_CDR3 = build_glanville_dataset(glanville_pre_CDR3_dict, glanville_myc_CDR3_dict)

    (CDR1 = glanville_dataset_CDR1,
     CDR2 = glanville_dataset_CDR2,
     CDR3 = glanville_dataset_CDR3)
end


"Download the Glanville VHH data"
function glanville_vhh_download()
    # if proxy, clone manually instead of calling this function!
    
    run(`mkdir -p $glanville_vhh_dir`)
    process_script = string(dirname(pathof(PhageData)) * "/../deps/process_glanville.sh")

    LibGit2.clone("git@gitlab.com:PhageDisplayInference/GlanvilleVHHData.git",
                  glanville_vhh_dir)

    cd(glanville_vhh_dir) do
        run(`tar -xvzf all-VHH-data.tgz -C $(pwd())`)
        run(`$process_script`)
    end

    write(glanville_vhh_dir * "/downloaded.txt", "Download complete")
end


"returns true if the Glanvile VHH data has been downloaded"
glanville_vhh_downloaded() = isfile(glanville_vhh_dir * "/downloaded.txt")



function glanville_vhh_load_CDRs(path)
    CDR1str = Vector{String}()
    CDR2str = Vector{String}()
    CDR3str = Vector{String}()

    for line in eachline(path)
        words = split(line, ';')
        @assert length(words) == 3
        if any(isempty, words)
            continue
        elseif any(w -> 'X' ∈ w, words) # missread amino acids
            continue
        end
        push!(CDR3str, words[1])
        push!(CDR1str, words[2])
        push!(CDR2str, words[3])
    end

    CDR1seqs = convert.(Sequence{20}, PhageData.str2seq.(CDR1str))
    CDR2seqs = convert.(Sequence{20}, PhageData.str2seq.(CDR2str))
    CDR3seqs = convert.(Sequence{20}, PhageData.str2seq.(CDR3str))
    
    (CDR1 = CDR1seqs, CDR2 = CDR2seqs, CDR3 = CDR3seqs)
end


function glavnille_vhh_build_dict(seqs)
    dict = Dict{Sequence,Int}()
    for s in seqs
        dict[s] = get(dict, s, 0) + 1
    end
    dict
end


function glanville_vhh_build_dataset(pre::Dict, pro::Dict)
    glanville_dict_data = [pre; pro]
    sequences = union(keys(pre), keys(pro)) |> collect |> Vector{Sequence{20}}
    S = length(sequences); T = length(glanville_dict_data); V = 1
    counts = [get(glanville_dict_data[t], sequences[s], 0) for s=1:S, v=1:V, t=1:T] |> float;
    glanville_dataset = DatasetNoAln(sequences, counts)
end