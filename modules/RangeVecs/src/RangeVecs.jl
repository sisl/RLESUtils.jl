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

"""
Convert to and from vectors of ints to a compact representation that uses
a vector of unit ranges.
"""
module RangeVecs

export RangeVec, iterator

using Iterators
import Base: collect, convert, string, show

typealias RangeVecType Union{Int64,UnitRange{Int64}}

type RangeVec
    ranges::Vector{RangeVecType}
end
RangeVec(v::Vector{Int64}) = convert(RangeVec, v) 
RangeVec() = RangeVec(Vector{RangeVecType}())

collect(rangevec::RangeVec) = convert(Vector, rangevec)

function convert(::Type{RangeVec}, v::Vector{Int64})
    if isempty(v)
        return RangeVec()
    end
    v1 = unique(v)
    sort!(v1)
    ranges = RangeVecType[]
    rstart = rstop = v1[1]
    for i = 2:length(v1)
        if v1[i] == rstop + 1
            rstop += 1
        else
            push!(ranges, make_range(rstart, rstop)) 
            rstart = rstop = v1[i]
        end
    end
    push!(ranges, make_range(rstart, rstop))
    RangeVec(ranges)
end

function make_range(rstart::Int64, rstop::Int64)
    if rstart == rstop 
        return rstart
    end
    rstart:rstop
end

function iterator(rangevec::RangeVec)
    chain(rangevec.ranges...)
end

function convert(::Type{Vector}, rangevec::RangeVec)
    collect(iterator(rangevec)) 
end

string(rangevec::RangeVec) = join(rangevec.ranges, ",")
show(io::IO, rangevec::RangeVec) = print(io, string(rangevec))

end #module
