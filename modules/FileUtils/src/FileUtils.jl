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

module FileUtils

export readdir_ext, readdir_dir, textfile, filenamefriendly, replace_in_files, 
    replace_text, isidentical 

import Compat.ASCIIString

using GZip

#readdir and filter for ext
function readdir_ext(ext::AbstractString, dir::AbstractString=".")
  files = readdir(dir)
  files = convert(Vector{ASCIIString}, files)
  filter!(f -> endswith(f, ext), files)
  map!(f -> joinpath(dir, f), files)
  return files
end

#readdir and filter for directories only
function readdir_dir(dir::AbstractString=".")
  fs = readdir(dir)
  fs = convert(Vector{ASCIIString}, fs)
  map!(f -> joinpath(dir, f), fs)
  filter!(isdir, fs)
  return fs
end

#fast way to make a textfile that outputs each arg and kwarg to a line
function textfile(file::AbstractString, args...; kwargs...)
  open(file, "w") do f
    for x in args
      println(f, x)
    end
    for (k, v) in kwargs
      println(f, k, "=", v)
    end
  end
end

#make string filesystem friendly
function filenamefriendly(s::AbstractString)
  s = replace(s, "[", "")
  s = replace(s, "]", "")
  s = replace(s, "(", "")
  s = replace(s, ")", "")
  s = replace(s, ":", "")
  s = replace(s, ",", "")
  s
end

function replace_in_files{T<:AbstractString}(files::Vector{T}, src::AbstractString, 
    dst::AbstractString; outdir::AbstractString="./converted", inplace::Bool=false)
    if !inplace
        mkpath(outdir)
    end
    for file in files
        fileroot, fileext = splitext(file)
        if fileext == ".gz" #Gzip format
            replace_text(file, src, dst, outdir, fopen=GZip.open, inplace=inplace)
        else #assume ascii-compatible
            replace_text(file, src, dst, outdir, fopen=open, inplace=inplace)
        end
    end
end

function replace_text(file::AbstractString, src::AbstractString, dst::AbstractString, 
    outdir::AbstractString; fopen::Function=open, inplace::Bool=false)
  text = fopen(readstring, file)
  text = replace(text, src, dst)

  if inplace
      outpath = file 
  else
      outpath = joinpath(outdir, basename(file))
  end
  fout = fopen(outpath, "w")
  write(fout, text)
  close(fout)
end

"""
compares two files byte by byte and returns whether they are identical
"""
function isidentical(file1::AbstractString, file2::AbstractString)
    f1 = open(file1, "r")
    f2 = open(file2, "r")
    issame = true

    #two ways to exit, bytes don't match or one file ends before other
    while !eof(f1) && !eof(f2)
        if read(f1, UInt8) != read(f2, UInt8)
            issame = false
            break
        end
    end
    if eof(f1) != eof(f2)
        issame = false
    end

    close(f1)
    close(f2)

    issame
end

end #module
