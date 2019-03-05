#= Here we acquire some binaries that are needed to
download and process the datasets. =#


#= All the commands and exectutables we use are 
for linux.... I don't know how to do it for general
OSes. =#

@info pwd()

@assert Sys.islinux() || Sys.isapple()

#=
    acquire sratoolkit 

Used to download SRA datasets.=#

@info "Downloading sratoolkit for Ubuntu (if you have a different OS, download manually)"
@info "This takes a couple of minutes ...."

if Sys.islinux()
    download("https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz", "sratoolkit.current-ubuntu64.tar.gz")
    run(`tar -xvzf sratoolkit.current-ubuntu64.tar.gz`)
elseif Sys.isapple()
    download("https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-mac64.tar.gz", "sratoolkit.current-mac64.tar.gz")
    run(`tar -xvzf sratoolkit.current-mac64.tar.gz`)
else
    error("should not end up here as only linux and apple are set")
end

namesradir = filter(x->occursin("sratoolkit",x)*isdir(x),readdir())[1]

run(`ln -s $namesradir sradir`)

@info "sratoolkit installed"


#=
    acquire unrtf 

Used to convert .rtf to .txt. We need this
because the Boyer 2016 PNAS suppl. files are
in .rtf format.

I'M NOT USING THIS ANYMORE. USE rtf2txt.sh INSTEAD, WHICH IS MUCH FASTER
=#
# @info "Downloading unrtf"
# download("https://www.gnu.org/software/unrtf/unrtf-0.21.9.tar.gz",
#          "unrtf-0.21.9.tar.gz")
# run(`tar -xvzf unrtf-0.21.9.tar.gz`)
# run(`mkdir -p unrtf-0.21.9-build`)
# println(pwd())
# cd("unrtf-0.21.9")
# @info "Building unrtf"
# run(`autoreconf -i`)
# run(`./configure --prefix=$(pwd())/../unrtf-0.21.9-build/`)
# run(`make`)
# run(`make install`)
# cd("..")
# @info "unrtf installed"
