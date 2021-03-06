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
Goes into each sub-directory of 'logdir', loads the 'logfile', extracts each log named 'logname',
stacks them all together into a single DataFrame, loads them into a TaggedDFLogger,
and saves the log to 'outfileroot'.txt.
Subdir name is loaded into column 'subdir_sym'.
All logs in TaggedDFLogger are then merged into a single DataFrame, joined on subdir name.
Main entry: logjoin()
"""
module LogJoiner

export logjoin

using DataFrames
using RLESUtils, Loggers, FileUtils, DataFrameUtils, StringUtils

function logjoin{T<:AbstractString}(logdir::AbstractString, logfile::AbstractString, 
    lognames::Vector{T}, join_on::Vector{Symbol}=Symbol[:name], 
    outfileroot::AbstractString=joinpath(logdir, "joined");
    transpose_syms::Vector{Union{Void,Symbol}}=Union{Void,Symbol}[],
    cast_types::Dict{String,Vector{Type}}=Dict{String,Vector{Type}}(),
    subdir_sym::Symbol=:name,
    verbose::Bool=false)

    if isempty(transpose_syms)
        transpose_syms = fill(nothing, length(lognames))
    end
    lognames = convert(Vector{String}, lognames)
    joined = TaggedDFLogger()
    for subdir in readdir_dir(logdir)
        verbose && println("subdir=$subdir")
        f = LogFile(joinpath(subdir, logfile))
        if !isfile(f.name)
            warn("file not found $(f.name), skipping...")
            break
        end
        logs = load_log(f)
        for (logname, sym) in zip(lognames, transpose_syms)
            verbose && println("  logname=$logname")
            D = logs[logname]
            if isa(sym, Symbol) #transpose if specified
                D = transpose(D, sym)
            end
            D[subdir_sym] = fill(basename(subdir), nrow(D))
            if haskey(cast_types, logname) #convert types if specified
                Ts = cast_types[logname]
                convert_col_types!(D, Ts)
            end
            if !haskey(joined, logname)
                set!(joined, logname, D)
            else
                append!(joined, logname, D)
            end
        end
    end
    save_log(LogFile("$outfileroot"), joined)

    D1 = join([joined[k] for k in lognames]...; on=join_on)
    writetable("$(outfileroot)_dataframe.csv.gz", D1) 

    joined
end

function logjoin(logdir::AbstractString, logfile::AbstractString, 
    outfileroot::AbstractString=joinpath(logdir,"joined"),
    verbose::Bool=false)

    joined = nothing
    for subdir in readdir_dir(logdir)
        verbose && println("subdir=$subdir")
        f = joinpath(subdir, logfile)
        if !isfile(f)
            warn("file not found $f, skipping...")
            break
        end
        d = readtable(f)
        if joined == nothing
            joined = d
        else
            append!(joined, d)
        end
    end

    writetable("$outfileroot.csv.gz", joined)
end

end #module
