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

# This module generates and manages runcases for setting parameters when doing many runs
# with varying parameter values.  e.g., parameter studies

module RunCases

using Iterators

import Base: get, start, done, next, length
export Case, Cases, generate_cases, add_field!, get, set!, savecase, loadcase

type Case
  data::Dict{String,Any}
end
Case() = Case(Dict{String, Any}())

type Cases
  data::Vector{Case}
end
Cases() = Cases(Case[])
Cases(case::Case) = Cases([case])

function generate_cases(keyvals::(String, Vector)...)
  #generates a vector of runcases based on cartesian product of the keyvals together
  #returns Cases
  #FIXME(rlee): This method of using vectors of the parameters uses a lot of space.  Switch it over to storing indices
  # and making each case on the fly as it is being iterated over
  kv_vec = map(kv_expand, keyvals)
  return Cases([make_case(kvs...) for kvs in product(kv_vec...)])
end

function add_field!(cases::Cases, field::String, value::Any)
  map(case -> set!(case, field, value), cases)
end

function add_field!{T <: String}(cases::Cases, field::String, getval::Function, lookups::Vector{T})
  map(case -> add_field!(case, field, getval, lookups), cases)
end

function add_field!{T <: String}(case::Case, field::String, getval::Function, lookups::Vector{T})
  # generate value of field dynamically by looking up keys already in the case, then calling callback gettag()
  values = map(l -> get(case, l), lookups)
  set!(case, field, getval(values...))
  return case
end

function get(case::Case, key::String)
  haskey(case.data, key) ? case.data[key] : nothing
end

set!(case::Case, key::String, value) = case.data[key] = value

function kv_expand(kV::(String, Vector))
  # expand (k, V) to a vector of where each element is (k, V_i)
  k, V = kV
  return convert(Array{(String,Any)}, map(x -> (k, x), V))
end

function make_case{S <: String}(kvs::(S, Any)...)
  # take all the (k, V_i) and populate a dict, then feed into Case
  d = Dict{String, Any}()
  for (k, v) in kvs
    d[k] = v
  end
  return Case(d)
end

function savecase(case::Case, filename::String="case.txt")
  f = open(filename, "w")
  for (k, v) in case.data
    println(f, "$k = $v")
  end
  close(f)
  return filename
end

function loadcase(filename=String="case.txt")
  f = open(filename)
  case = Case()
  for line in eachline(f)
    k, v = split(line, "=")
    case.data[strip(k)] = strip(v)
  end
  close(f)
  return case
end

# iterator for Case
start(case::Case) = start(case.data)
done(case::Case, state) = done(case.data, state)
next(case::Case, state) = next(case.data, state)
length(case::Case) = length(case.data)

# iterator for Cases
start(cases::Cases) = start(cases.data)
done(cases::Cases, state) = done(cases.data, state)
next(cases::Cases, state) = next(cases.data, state)
length(cases::Cases) = length(cases.data)

end #module
