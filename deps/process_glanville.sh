#!/bin/bash
# author: cossio

# Process Glanville's VHH fasta files

for f in *.fa; do
	echo "Processing $f"
	grep '>M00' $f | awk -F ";" '{OFS=";"; print($5,$9,$10)}' > $(basename $f)_CDRs.txt
done
