module StringUtils

import Base.bool

export hamming, TRUES, FALSES

const TRUES = ASCIIString["TRUE", "T", "+", "1", "1.0", "POS", "POSITIVE"]
const FALSES = ASCIIString["FALSE", "F", "-1", "0", "0.0", "NEG", "NEGATIVE"]

function hamming(s1::String, s2::String)
  x = collect(s1)
  y = collect(s2)
  minlen = min(length(x), length(y))
  len_diff = abs(length(x) - length(y))
  return sum(x[1:minlen] .!= y[1:minlen]) + len_diff
end

function bool(s::String)
  s_ = uppercase(s)
  if in(s_, TRUES)
    return true
  elseif in(s_, FALSES)
    return false
  else
    throw(InexactError())
  end
end

end #module
