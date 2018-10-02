# *****************************************************************************
# Written by Ritchie Lee, ritchie.lee@sv.cmu.edu
# *****************************************************************************
# Copyright ã 2015, United States Government, as represented by the
# Administrator of the National Aeronautics and Space Administration. All
# rights reserved.  The Reinforcement Learning Encounter Simulator (RLES)
# platform is licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You
# may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0. Unless required by applicable
# law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the specific language
# governing permissions and limitations under the License.
# _____________________________________________________________________________
# Reinforcement Learning Encounter Simulator (RLES) includes the following
# third party software. The SISLES.jl package is licensed under the MIT Expat
# License: Copyright (c) 2014: Youngjun Kim.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED
# "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# *****************************************************************************

module ArrayUtils

export elements_equal, duplicate!, consec_unique, consec_unique_inds

using Base.Iterators

"""
Returns true if all elements in the vector are equal to each other
"""
function elements_equal{T}(x::Vector{T})
  for (x1, x2) in partition(x, 2, 1)
    x1 != x2 && return false
  end
  return true
end

"""
resize and copy! in 1 call
"""
function duplicate!{T}(x::Vector{T}, y::Vector{T})
  resize!(x, length(y))
  copy!(x, y)
end

"""
Remove consecutive duplicates
"""
function consec_unique{T}(v::AbstractVector{T})
    v1 = Vector{T}()
    if length(v) > 0
        laste = v[1]
        push!(v1, laste)
        for e in v
            if e != laste
                laste = e
                push!(v1, laste)
            end
        end
    end
    v1
end

"""
Same as consec_uniq, but return the indices
"""
function consec_unique_inds{T}(v::AbstractVector{T})
    inds = Vector{Int64}()
    if length(v) > 0
        laste = v[1]
        push!(inds, 1)
        i = 1
        for e in v
            if e != laste
                laste = e
                push!(inds, i)
            end
            i += 1
        end
    end
    inds 
end

end #module
