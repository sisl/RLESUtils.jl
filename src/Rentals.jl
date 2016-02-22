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

#memory pool, preallocate a collection of objects, checkout from pool and checkin when done
#dynamically allocate more until max_allocs
module MemPools

export MemPool, checkin, checkout

import Base: length, eltype

using DataStructures

immutable MaxSizeException <: Exception end

type MemPool{T}
  T::Type
  inventory::Stack{Deque{T}}
  n_allocs::Int64
  max_allocs::Int64
end

function MemPool(T::Type, init_allocs::Int64, max_allocs::Int64)
  rental = MemPool(T, Stack(T), 0, max_allocs)
  allocate!(rental, init_allocs)
  return rental
end

function checkout{T}(rental::MemPool{T})
  if isempty(rental.inventory)
    return allocate(rental)
  else
    return pop!(rental.inventory)
  end
end

function checkin{T}(rental::MemPool{T}, obj::T)
  push!(rental.inventory, obj)
end

length{T}(rental::MemPool{T}) = length(rental.inventory)
eltype{T}(rental::MemPool{T}) = T

function allocate!{T}(rental::MemPool{T}, N::Int64)
  for i = 1:N
    push!(rental.inventory, allocate(rental))
  end
end

function allocate{T}(rental::MemPool{T})
  if rental.n_allocs >= rental.max_allocs
    throw(MaxSizeException())
  end
  rental.n_allocs += 1
  return rental.T()
end

end #module
