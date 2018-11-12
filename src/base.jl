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


"""
    clean!(data)

Modifies data in-place, setting N[s,v,t] to zero if
N[s,v,t0] was zero for any 0 < t0 < t.
"""
function clean!(data::Dataset)
    S, V, T = size(data.N)
    for v = 1:V, s = 1:S
        if iszero(data.N[s,v,1])
            for t = 2:T
                data.N[s,v,t] = zero(data.N[s,v,t])
            end
        end
    end
end


"""
    clean(data)

Like clean!(data), but returns a copy of the data,
leaving the original unmodified.
"""
function clean(data::Dataset)
    d = deepcopy(data)
    clean!(d)
    d
end


"""
    rmzero(data)

Returns a copy of data where sequences with
zero counts in all rounds and replicates have
been removed.
"""
function rmzero(data::Dataset)
    S, V, T = size(data.N)
    flag = fill(false, S)
    v = t = 0
    s = 1
    for s = 1:S
        for t = 1:T, v = 1:V
            if !iszero(data.N[s,v,t])
                flag[s] = true
                break
            end
        end
    end
    
    Dataset(data.sequences[flag], data.N[flag,:,:])
end