# acquire sratoolkit
@info "Downloading sratoolkit for Ubuntu (if you have a different OS, download manually)"
@info "This takes a couple of minutes ...."
dest = string(@__DIR__, "/sratoolkit.current-ubuntu64.tar.gz")
download("https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz", dest)
run(`tar -xvzf $dest`)
