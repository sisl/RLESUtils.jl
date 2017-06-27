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

module MutexLRUCaches

export MutexLRUCache

using LRUCache
using Base.Threads

import Base: get, setindex!, get!, empty!, length, isempty

type MutexLRUCache{K,V}
    mutex::Mutex
    lru::LRU{K,V}

    function MutexLRUCache(maxsize::Int64=100)
        new(Mutex(), LRU{K,V}(maxsize))
    end
end

"""
Atomic get.  Locks the mutex, fetches the value specified by key, then unlocks.
Returns value if it exists, otherwise returns default.
"""
function get{K,V}(cache::MutexLRUCache{K,V}, key::K,
    default::Any=nothing)
    lock(cache.mutex)
    value = get(cache.lru, key, default)
    unlock(cache.mutex)
    value
end

"""
Same as get but do-block syntax
"""
function get!{K,V}(default::Base.Callable, cache::MutexLRUCache{K,V}, 
    key::K; empty_value::Any=nothing)
    value = get(cache, key, empty_value)
    if value == empty_value 
        value = default() #not locked here
        setindex!(cache, value, key)
    end
    value
end

"""
Atomic set.  Locks the mutex, sets the value to the location of the key,
then unlocks.
"""
function setindex!{K,V}(cache::MutexLRUCache{K,V}, 
    value::V, key::K)
    lock(cache.mutex)
    setindex!(cache.lru, value, key) 
    unlock(cache.mutex)
end

function empty!{K,V}(cache::MutexLRUCache{K, V})
    lock(cache.mutex)
    empty!(cache.lru)
    unlock(cache.mutex)
end

length{K,V}(cache::MutexLRUCache{K,V}) = length(cache.lru)
isempty{K,V}(cache::MutexLRUCache{K,V}) = isempty(cache.lru)

end #module
