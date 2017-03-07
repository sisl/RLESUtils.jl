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

module D3Trees

export plottree, openbrowser, plotcollection

using JSON, GZip

const DIR = dirname(@__FILE__)
const HTML = joinpath(DIR, "index.html")
const DST = joinpath(DIR, "data.json")

function plottree(d::Dict{AbstractString,Any}, openviewer::Bool=false;
                  python_version::Int64=3)
  open(DST, "w") do f
    JSON.print(f, d)
  end
  if openviewer
    startserver(python_version=python_version)
    openbrowser()
  end
end

function plottree(file::AbstractString, openviewer::Bool=false;
                  python_version::Int64=3)
  #cp the json file to local directory
  cp(file, DST, remove_destination=true)
  if openviewer
    startserver(python_version=python_version)
    openbrowser()
  end
end

function plotcollection(file::AbstractString; python_version::Int64=3)
  D = if endswith(file, ".json")
    open(file) do f
      JSON.parse(f)
    end
  elseif endswith(file, ".gz")
    GZip.open(file) do f
      JSON.parse(f)
    end
  else
    error("Extension not recognized")
  end
  startserver(python_version=python_version)
  for d in D
    open(DST, "w") do f
      JSON.print(f, d)
    end
    openbrowser()
  end
end

function startserver(; python_version::Int64=3, delay::Float64=0.5)
  currentdir = pwd()
  cd(DIR)
  #start a local python server
  started = if python_version == 3
    success(`cmd /c start python -m http.server 8888 &`)
  elseif python_version == 2
    success(`cmd /c start python -m http.server 8888 &`) #this isn't right...
  else
    error("python version not recognized: $(python_version)")
  end
  cd(currentdir)
  sleep(delay)
end

#windows only!
function openbrowser(; delay::Float64=0.5)
  currentdir = pwd()
  cd(DIR)
  #start a browser and point it at HTML
  success(`cmd /c start http://localhost:8888/index.html`)
  cd(currentdir)
  sleep(delay)
end

end # module

#TODO: cleanup open processes
#TODO: only works on windows
