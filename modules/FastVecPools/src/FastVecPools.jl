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
Maintains a pre-allocated pool of vectors.  You can check out vectors
and return them to the pool.  Vectors are initialized to vec_size.
Primary use is to avoid repeated temporary vector allocations
Vectors are not initialized at checkout.
"""
module FastVecPools

export FastVecPool, checkout, check_in_all, available

type FastVecPool{T}
    items::Vector{Vector{T}}
    index::Int64 #index-1 of next available vector

    function FastVecPool(vec_size::Int64, pool_size::Int64)
        items = [Vector{T}(vec_size) for i=1:pool_size]
        new(items, 0)
    end
end

"""
Check out a vector from pool
"""
function checkout(pool::FastVecPool)
    pool.index += 1
    pool.items[pool.index] #if max size is exceeded, will throw out of bounds exception
end


"""
Check in all vectors to pool
"""
function check_in_all(pool::FastVecPool)
    pool.index = 0
end

"""
Number of available vectors left in pool
"""
function available(pool::FastVecPool)
    length(pool.items) - pool.index
end

end #module
