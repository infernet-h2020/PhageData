# acquire sratoolkit

@info "Downloading sratoolkit for Ubuntu (if you have a different OS, download manually)"
@info "This takes a couple of minutes ...."
download("https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz",
            "sratoolkit.current-ubuntu64.tar.gz")
run(`tar -xvzf sratoolkit.current-ubuntu64.tar.gz`)
@info "sratoolkit installed"


# acquire unrtf
@info "Downloading unrtf"
download("https://www.gnu.org/software/unrtf/unrtf-0.21.9.tar.gz",
         "unrtf-0.21.9.tar.gz")
run(`tar -xvzf unrtf-0.21.9.tar.gz`)
run(`mkdir -p unrtf-0.21.9-build`)
println(pwd())
cd("unrtf-0.21.9")
@info "Building unrtf"
run(`autoreconf -i`)
run(`./configure --prefix=$(pwd())/../unrtf-0.21.9-build/`)
run(`make`)
run(`make install`)
cd("..")
@info "unrtf installed"
