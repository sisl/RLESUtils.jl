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
Example usage:\n
#create logger\n
logs = TaggedDFLogger()\n
add_folder!(logs, "mylog1", [Int64, Float64], [:x1, :x2])\n
add_folder!(logs, "mylog2", [Bool, String], [:y1, :y2])\n
#create observer\n
observer = Observer()\n
add_observer(observer, "signal1", push!_f(logs, "mylog1"))\n
#in executing code, pass data into observer\n
@notify_observer(observer, "signal1", [1, 2.0]) \n
#when done, save to file\n
save_log("logfile.txt", logs)\n
#load it back to view\n
logs = load_log(TaggedDFLogger, "logfile.txt")\n
logs["mylog1"]\n
logs["mylog2"]
"""
module Loggers

export LogFile, Logger, get_log, empty!, push!,setindex!, getindex, haskey, 
    start, next, done, length, push!_f, append_push!_f, save_log, load_log, 
    keys, values, set!, name
export TaggedDFLogger, add_folder!, add_varlist!
export save_log_old, load_log_old #deprecated, for legacy compat only

using DataFrames
using ZipFile

import Base: empty!, push!, setindex!, getindex, haskey, start, next, done, length, keys, 
    values, append!
import Base.transpose

abstract Logger

immutable LogFile
   name::String

   function LogFile(file::AbstractString)
        if !endswith(file, ".zip")
            file *= ".zip"
        end
        new(file)
    end
end

name(logfile::LogFile) = logfile.name

type TaggedDFLogger <: Logger
    data::Dict{String,DataFrame}
end
TaggedDFLogger() = TaggedDFLogger(Dict{String,DataFrame}())

push!_f(logger::TaggedDFLogger, tag::AbstractString) = x -> push!(logger, tag, x)
function append_push!_f(logger::TaggedDFLogger, tag::AbstractString, appendx)
    return x -> begin
        x = convert(Vector{Any}, x)
        push!(x, appendx...)
        return push!(logger, tag, x)
    end
end

function add_varlist!(logger::TaggedDFLogger, tag::AbstractString)
    add_folder!(logger, tag, [String, Any], ["variable", "value"])
end

function add_folder!{T<:Type,S<:AbstractString}(logger::TaggedDFLogger, tag::AbstractString, 
    eltypes::Vector{T}, elnames::Vector{S})
    add_folder!(logger, tag, eltypes, map(Symbol, elnames))
end

function add_folder!{T<:Type}(logger::TaggedDFLogger, tag::AbstractString, 
    eltypes::Vector{T}, elnames::Vector{Symbol}=Symbol[])
    if !haskey(logger, tag)
        logger.data[tag] = DataFrame(eltypes, elnames, 0)
    else
        warn("TaggedDFLogger: Folder already exists: $tag")
    end
    logger
end

function save_log(logfile::LogFile, logger::TaggedDFLogger)
    file = logfile.name
    w = ZipFile.Writer(file)
    for (tag, log) in get_log(logger)
        f = ZipFile.addfile(w, "$tag.csv")
        printtable(f, log)
    end
    close(w)
end

function load_log(logfile::LogFile)
    file = logfile.name
    logger = TaggedDFLogger()
    r = ZipFile.Reader(file)
    for f in r.files
        tag = splitext(basename(f.name))[1]
        logger.data[tag] = readtable(f) 
    end
    close(r)
    logger
end

function save_log_old(file::AbstractString, logger::TaggedDFLogger)
    warn("save_log_old is deprecated")
    fileroot = splitext(file)[1]
    f = open(file, "w")
    println(f, "__type__=TaggedDFLogger")
    for (tag, log) in get_log(logger)
        fname = "$(fileroot)_$tag.csv.gz"
        println(f, "$tag=$(basename(fname))")
        writetable(fname, log)
    end
    close(f)
end

function load_log_old(file::AbstractString)
    warn("load_log_old is deprecated")
    dir = dirname(file)
    logger = TaggedDFLogger()
    f = open(file)
    for line in eachline(f)
        line = chomp(line)
        k, v = split(line, "=")
        if k == "__type__" #crude typechecking
            if v != "TaggedDFLogger"
                error("TaggedDFLogger: Not a TaggedDFLogger file!")
            end
        else
            tag, dffile = k, v
            try
                D = readtable(joinpath(dir, dffile))
                logger.data[tag] = D
            catch
                warn("logs[\"$tag\"] could not be restored")
            end
        end
    end
    close(f)
    logger
end

function push!(logger::TaggedDFLogger,tag::AbstractString, x) 
    try
        push!(logger.data[tag], x)
    catch e
        println("tag=$tag, x=$(string(x))")
        rethrow(e)
    end
end

get_log(logger::TaggedDFLogger) = logger.data
get_log(logger::TaggedDFLogger, tag::AbstractString) = logger.data[tag]
set!(logger::TaggedDFLogger, tag::AbstractString, D::DataFrame) = logger.data[tag] = D
append!(logger::TaggedDFLogger, tag::AbstractString, D::DataFrame) = append!(logger.data[tag], D)

keys(logger::TaggedDFLogger) = keys(logger.data)
values(logger::TaggedDFLogger) = values(logger.data)
haskey(logger::TaggedDFLogger, tag::AbstractString) = haskey(logger.data, tag)
getindex(logger::TaggedDFLogger, tag::AbstractString) = logger.data[tag]
setindex!(logger::TaggedDFLogger, x, tag::AbstractString) = logger.data[tag] = x
empty!(logger::TaggedDFLogger) = empty!(logger.data)
start(logger::TaggedDFLogger) = start(logger.data)
next(logger::TaggedDFLogger, s) = next(logger.data, s)
done(logger::TaggedDFLogger, s) = done(logger.data, s)
length(logger::TaggedDFLogger) = length(logger.data)

function transpose(D::DataFrame, namecol::Symbol; rows::Vector{Symbol}=Symbol[])
    cnames = convert(Array{Symbol}, D[namecol]) 
    ctypes = convert(Array{Type}, fill(Any, nrow(D)))
    Dout = DataFrame(ctypes, cnames, 0) 
    if isempty(rows)
        rows = filter(x->x != namecol, names(D))
    end
    for r in rows
        push!(Dout, D[r])
    end
    Dout[:colnames] = rows
    Dout
end

end #module
