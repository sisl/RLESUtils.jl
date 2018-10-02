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

#DEPRECATED!  Do not use for new projects!! No replacement yet though.
# Converts a type object to a json-compatible Dict for saving.  Easy recovery to original type.
# Supports arrays, but not Unions

module Obj2Dict

#export to_obj, to_dict, save_obj, load_obj

import Base.convert
using JSON
using DataStructures
using RLESUtils, StringUtils

typealias ObjDict{T<:AbstractString} Dict{T,Any}
typealias Primitive Union{Integer, Real, AbstractString, Symbol, Void}

function to_dict(x)
  d = ObjDict{String}()
  d["type"] = string(typeof(x))
  d["data"] = ObjDict{String}()
  for sym in fieldnames(x)
    d["data"][string(sym)] = to_dict(getfield(x, sym))
  end
  return d
end

function to_dict(x::Primitive)
  d = ObjDict{String}()
  d["type"] = string(typeof(x))
  d["data"] = x
  return d
end

function to_dict(x::Array)
  if isempty(x)
    out = Any[]
    for i = 1:ndims(x) - 1
      out = Any[out]
    end
    return out
  else
    d = ObjDict{String}()
    return map(to_dict, x)
  end
end

function to_dict(x::Dict)
  d = ObjDict{String}()
  d["type"] = string(typeof(x))
  d["data"] = ObjDict{String}()
  for (k, v) in x
    d["data"][string(k)] = to_dict(v)
  end
  return d
end

function to_dict(x::Expr)
  d = ObjDict{String}()
  d["type"] = string(typeof(x))
  d["data"] = string(x)
  return d
end

function to_dict(x::Function)
  #warn("Function excluded in Obj2Dict") #drop silently or verbosely?
  d = ObjDict{String}()
  d["type"] = string(Function)
  d["data"] = 0 #not supported at the moment
  return d
end

function to_dict{T}(x::Stack{Deque{T}})
  d = ObjDict{String}()
  d["type"] = string(typeof(x))
  d["data"] = convert(Array, x)
  return d
end

function set_fields!(x, d::ObjDict; verbose::Bool=true)
  for sym in fieldnames(x)
    if haskey(d["data"], string(sym))
      setfield!(x, sym, to_obj(d["data"][string(sym)]))
    elseif verbose
      warn("Obj2Dict::set_fields!: ($sym) not found!")
    end
  end
  return x
end

function set_entries!{T1,T2}(x::Dict{T1,T2}, d::ObjDict)
  for (k, v) in d["data"]
    k_ = convert(T1, k)
    x[k_] = to_obj(v)
  end
  return x
end

#TODO: Make these more elegant. e.g., use dispatch
#Don't access through Main and don't assume empty constructor exists.
function to_obj(d::ObjDict)
  if haskey(d, "type") && haskey(d, "data")
    T = eval(Main, parse(d["type"])) #TODO: remove access through Main
    if issubtype(T, Dict)
      x = T()
      set_entries!(x, d)
    elseif issubtype(T, Primitive)
      x = convert(T, d["data"])
    elseif issubtype(T, Expr)
      x = parse(d["data"])
    elseif issubtype(T, Function) #functions not supported, but still handle gracefully
      x = () -> error("Obj2Dict: Function was stripped")
    elseif  issubtype(T, Stack)
      x = convert(Stack, d["data"])
    else
      x = to_datatype(T, d)
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

function to_datatype(T, d::ObjDict)
  x = nothing
  try
    x = T()  #assume an empty constructor exists through Main
    set_fields!(x, d)
  catch
    try
      #try struct-style default constructor
      fields = map(field -> to_obj(d["data"][string(field)]), fieldnames(T))
      x = T(fields...)
    catch e
      println("exception $e")
      warn("Could not restore: $T")
    end
  end
  return x
end

function save_obj(file::AbstractString, x)
  f = open(file, "w")
  d = to_dict(x)
  JSON.print(f, d)
  close(f)
  return file
end

function load_dict(file::AbstractString)
  f = open(file, "r")
  d = JSON.parse(f)
  close(f)
  return d
end

function load_obj(file::AbstractString)
  d = load_dict(file)
  x = Obj2Dict.to_obj(d)
  return x
end

#workaround for JSON limitation that cannot recover 2D arrays.  They get recovered
#to vector of vector
convert{T}(::Type{Array{T,2}}, x::Array{Array{T,1},1}) = hcat(x...)
convert{T}(::Type{Array{T,2}}, x::Array{Array{Union{},1},1}) = Array(T, 0, 0)
convert{T}(::Type{Stack{Deque{T}}}) = Stack(T)

function convert{T}(::Type{Array}, S::Stack{Deque{T}})
  S_copy = deepcopy(S)
  v = T[]
  while !isempty(S_copy)
    push!(v, pop!(S_copy))
  end
  return v
end

function convert{T}(::Type{Stack}, v::Vector{T})
  v_copy = deepcopy(v)
  S = Stack(T)
  while !isempty(v_copy)
    push!(S, pop!(v_copy))
  end
  return S
end

end #module
