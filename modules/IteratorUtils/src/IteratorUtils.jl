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

module IteratorUtils

export roundrobin

import Base: start, next, done, length

typealias Iterable Any

type RoundRobinIter
  subiters::Vector{Iterable}
  states::Vector{Any}
  isdone::Vector{Bool}
end

function RoundRobinIter(iters::Tuple{Vararg{Iterable}}, states::Vector{Any}, isdone::Vector{Bool})
  iterarray = [iters[i] for i = 1:length(iters)]
  RoundRobinIter(iterarray, states, isdone)
end

"""
Iterate over a list of iterables in round robin style
e.g., collect(roundrobin([1,4], [2,5],[3,6,7])) #gives [1,2,3,4,5,6,7]
"""
function roundrobin(iters::Iterable...)
  RoundRobinIter(iters, Array(Any, length(iters)), fill(false, length(iters)))
end

function start(iter::RoundRobinIter)
  for i in eachindex(iter.subiters)
    iter.states[i] = start(iter.subiters[i])
  end
  index = 1
end


function next(iter::RoundRobinIter, index::Int64)
  total = 0
  while iter.isdone[index]
    index = nextindex(index, length(iter.subiters))
    total += 1
    if total > length(iter.subiters) #we've made a full circle and found nothing, quit
      return nothing
    end
  end
  item, iter.states[index] = next(iter.subiters[index], iter.states[index])
  if done(iter.subiters[index], iter.states[index])
    iter.isdone[index] = true
  end
  index = nextindex(index, length(iter.subiters))

  item, index
end

function done(iter::RoundRobinIter, index::Int64)
  all(iter.isdone)
end

#cycle through indices
function nextindex(index::Int64, maxindex::Int64)
  index < maxindex ? index + 1 : 1
end

function length(iter::RoundRobinIter)
    sum(map(length, iter.subiters))
end

end #module
