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
Depth-first traverse over a tree and writes to a JSON file.  Interaction is generic, based on callbacks.
name=get_name(node), iterable(edgename,childnode)=get_chidren(node),depth=get_depth(node).
Usage:
Populate the callbacks into VisCalls and pass root node into write_json (output to file) or
to_jdict (output to dict)
"""
module TreeToJSON

export to_jdict, write_json, VisCalls, JDict

using JSON

typealias JDict Dict{AbstractString,Any}

type VisCalls
  get_name::Function #name = get_name(node)
  get_children::Function #get_children(node) give iterable of (edgelabel, child)
  get_depth::Nullable{Function}
end

function VisCalls(get_name::Function, get_children::Function)
  return VisCalls(get_name, get_children, Nullable{Function}())
end

function VisCalls(get_name::Function, get_children::Function, get_depth::Function)
  return VisCalls(get_name, get_children, Nullable{Function}(get_depth))
end

"""
Like to_jdict except writes output to json file.
"""
function write_json(treeroot, vc::VisCalls, filename::AbstractString="treeview.json";
                    kvs...)
  d = to_jdict(treeroot, vc, kvs...)
  f = open(filename, "w")
  JSON.print(f, d)
  close(f)
  return filename::AbstractString
end

"""
Depth-first traverse over tree and output to json object.  Input the root node and the callbacks.
Keyword arguments are mapped to additional "user" fields in the json, the value should be a callback
function of the f(node).
For example: write_json(tree.root, f, height=get_height, color=get_color)
"""
function to_jdict(treeroot, vc::VisCalls; kvs...)
  userfields = Dict{ASCIIString,Function}()
  for (k, f) in kvs
    userfields[string(k)] = f
  end
  return process(treeroot, vc, userfields, 0)::JDict
end

function process(node, vc::VisCalls, userfields::Dict{ASCIIString,Function}, depth::Int64)
  d = JDict()
  d["name"] = vc.get_name(node)
  d["depth"] = !isnull(vc.get_depth) ? get(vc.get_depth)(node) : depth

  for (k, f) in userfields
    d[k] = f(node)
  end

  d["edgeLabel"] = ASCIIString[]
  d["children"] = JDict[]
  for (edgelabel, child) in vc.get_children(node)
    push!(d["edgeLabel"], string(edgelabel))
    push!(d["children"], process(child, vc, userfields, depth + 1))
  end
  return d::JDict
end

end #module
