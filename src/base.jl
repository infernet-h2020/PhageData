"amino acid letter to integer"
const aa2int = Dict('A' => 1, 'C' => 2, 'D' => 3, 'E' => 4, 'F' => 5, 
                            'G' => 6, 'H' => 7, 'I' => 8, 'K' => 9, 'L' => 10, 
                            'M' => 11, 'N' => 12, 'P' => 13, 'Q' => 14, 'R' => 15, 
                            'S' => 16, 'T' => 17, 'V' => 18, 'W' => 19, 'Y' => 20,
                            '*' => 21)
@assert allunique(values(aa2int))

"integer to amino acid letter"
const int2aa = Dict(k => aa for (aa,k) in aa2int)

"convert amino acid sequence string (one letter codes) to Sequence{21,L}"
str2seq(s::String) = Sequence{21}(get.(Ref(aa2int), collect(s), nothing))

"convert Sequence{21,L} to amino acid sequence string (one letter codes)"
seq2str(s::Sequence{21,L}) where {L} = join(get.(Ref(int2aa), s.s, nothing))


"reads a .fastq.prot.counts file into a DataFrame"
readcounts(path::String) = CSV.read(path; delim='\t', header=["seq", "N"], types=[String, Int])

"number of gaps in an alignment"
count_gaps(a) = BioAlignments.count_insertions(a) + BioAlignments.count_deletions(a)
