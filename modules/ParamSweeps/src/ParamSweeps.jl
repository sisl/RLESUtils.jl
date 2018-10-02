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

##Usage
#
#
module ParamSweeps

export ParamSweep, Iterable, run
export KWParamSweep

using Base.Iterators

import Base: empty!, push!, run, start, next, done, keys, values, length

typealias Iterable Any

type ParamSweep
  f::Function #function to be called
  argsrc::Vector{Iterable} #vector of iterables, cartesian product will be called on f
end

ParamSweep(f::Function) = ParamSweep(f, Iterable[])
function ParamSweep(f::Function, argsrc::Iterable...)
  script = ParamSweep(f) #this construction avoids infinite recursions caused by Iterable being Any
  push!(script, argsrc...)
  return script
end

function run(script::ParamSweep)
  map(product(script.argsrc...)) do args
    script.f(args...)
  end
end

push!(script::ParamSweep, iterable::Iterable) = push!(script.argsrc, iterable)
push!(script::ParamSweep, iterables::Iterable...) = push!(script.argsrc, iterables...)
empty!(script::ParamSweep) = empty!(script.argsrc)

##########

type KWParamSweep
  f::Function #function to be called
  argsrc::Dict{Symbol,Iterable} #keyed iterables, cartesian product will be called on f
end

KWParamSweep(f::Function; kwargs::Iterable...) = KWParamSweep(f, Dict{Symbol,Iterable}(kwargs))

function run(script::KWParamSweep)
  map(script) do kwargs
    script.f(; kwargs...)
  end
end

#incremental build of param iterables
push!(script::KWParamSweep, key::Symbol, iterable::Iterable) = script.argsrc[key] = iterable
empty!(script::KWParamSweep) = empty!(script.argsrc)

type KWIteratorState
  it
  state
end

function start(script::KWParamSweep)
  it = product(values(script.argsrc)...)
  return KWIteratorState(it, start(it))
end

function next(script::KWParamSweep, s::KWIteratorState)
  vals, s.state = next(s.it, s.state)
  x = collect(zip(keys(script), vals))
  return x, s
end

done(script::KWParamSweep, s::KWIteratorState) = done(s.it, s.state)
length(script::KWParamSweep) = prod(map(length, values(script)))

keys(script::KWParamSweep) = keys(script.argsrc)
values(script::KWParamSweep) = values(script.argsrc)

end #module
