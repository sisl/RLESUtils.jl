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

# Converts a type object to a json-compatible Dict for saving.  Easy recovery to original type.
# Supports arrays, but not Unions

module Obj2Dict

import Base.convert

typealias ObjDict Dict{String, Any}
typealias Primitive Union(Dict, Integer, Real, String, Symbol, Nothing)

function to_dict(x)

  d = ObjDict()
  d["type"] = string(typeof(x))
  d["data"] = ObjDict()
  for sym in names(x)
    d["data"][string(sym)] = to_dict(x.(sym))
  end

  return d
end

function to_dict(x::Primitive)
  d = ObjDict()
  d["type"] = string(typeof(x))
  d["data"] = x

  return d
end

function to_dict(x::Array)
  d = ObjDict()
  map(to_dict, x)
end

function set_fields!(x, d::ObjDict; verbose::Bool = true)

  for sym in names(x)
    if haskey(d, string(sym))
      x.(sym) = to_obj(d[string(sym)])

    elseif verbose
      warn("Obj2Dict::set_fields!: ($sym) not found!")
    end
  end

  return x
end

function to_obj(d::ObjDict)

  if haskey(d,"type") && haskey(d,"data")

    T = Main.(symbol(d["type"]))       #access through Main

    if issubtype(T, Primitive)
      x = convert(T, d["data"])
    else
      x = T()  #assume an empty constructor exists
      set_fields!(x, d["data"])
    end

    return x::T
  else
    return d
  end

end

function to_obj(d::Array)
  x = map(to_obj, d) #call to_obj on each element

  T = promote_type(map(typeof, x)...) #determine the lowest common type
  return convert(Array{T}, x)
end

to_obj(x) = x

#workaround for JSON limitation that cannot recover 2D arrays.  They get recovered
#to vector of vector
convert{T<:Any}(::Type{Array{T, 2}}, x::Array{Array{T, 1}, 1}) = hcat(x...)

end #module
