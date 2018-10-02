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

module Observers

export Observer, add_observer, @notify_observer, @notify_observer_default

import Base: empty!, delete!

mutable struct Observer
  callbacks::Dict{String,Vector{Function}}
end
Observer() = Observer(Dict{String, Vector{Function}}())

function add_observer(obs::Observer, tag::String, f::Function)
  if !haskey(obs.callbacks, tag)
    obs.callbacks[tag] = Function[]
  end
  push!(obs.callbacks[tag], f)
end

add_observer(obs::Observer, f::Function) = add_observer(obs, "_default", f::Function)

#macro form allows allocations in arg to be no cost
#i.e., in a functional form notify_observer(obs, tag, big_alloc()) will occur immediately
#but avoided in macro form
macro notify_observer(obs, tag, arg)
  quote
    if haskey($(esc(obs)).callbacks, $tag)
      for f in $(esc(obs)).callbacks[$tag]
        f($(esc(arg)))
      end
    end
  end
end

#there's no multiple dispatch on macros, so need a unique name
macro notify_observer_default(obs, arg)
  quote
    @notify_observer($(esc(obs)), "_default", $(esc(arg)))
  end
end

empty!(obs::Observer) = empty!(obs.callbacks)
delete!(obs::Observer, tag::String="_default") = delete!(obs.callbacks, tag)

end #module
