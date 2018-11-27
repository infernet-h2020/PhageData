import LibGit2

const glanville_vhh_dir = DATAPATH * "/glanville"


"""
    glanville_cam()

Returns Glanville Cam dataset.
If the dataset has not been downloaded, it downloads the
original data (this can take a while, but is only done once).
"""
function glanville_cam()
    #= if the dataset is not available,
    download and/or process it =#
    if !glanville_downloaded()
        glanville_download()
    end

    #= load dataset into Julia =#
    
end


"Download the Boyer 2016 PNAS paper dataset"
function glanville_download()
    # if proxy, clone manually instead of calling this function!
    LibGit2.clone("git@gitlab.com:PhageDisplayInference/GlanvilleVHHData.git",
                  glanville_vhh_dir)
    cd(glanville_vhh_dir) do
        run(`tar -xvzf all-VHH-data.tgz -C $(pwd())`)
        process_script = string(pathof(PhageData) * "/deps/process_glanville.sh")
        run(`$process_script`)
    end
    write(glanville_vhh_dir * "/downloaded.txt", "Download complete")
end


"returns true if the Glanvile data has been downloaded"
glanville_downloaded() = isfile(glanville_vhh_dir * "/downloaded.txt")
