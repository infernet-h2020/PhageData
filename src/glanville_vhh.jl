import LibGit2

const glanville_vhh_dir = DATAPATH * "/glanville_vhh"


"""
    glanville_vhh_cam()

Returns Glanville Cam dataset.
If the dataset has not been downloaded, it downloads the
original data (this can take a while, but is only done once).
"""
function glanville_vhh_cam()
    #= if the dataset is not available,
    download and/or process it =#
    if !glanville_vhh_downloaded()
        glanville_vhh_download()
    end

    #= load dataset into Julia =#
    
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
