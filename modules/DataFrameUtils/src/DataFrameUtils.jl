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

module DataFrameUtils

export convert_col_types!, convert_to_array_cols!, find_in_col, join_all,
    PadMethod, ZeroPad, FillPad, RepeatLastPad, pad!, names_by_type

using DataFrames
using StringUtils

"""
Convert the columns of a dataframe D to specified types 
"""
function convert_col_types!(D::DataFrame, target_types::Vector{Type}, 
    cols::Vector{Symbol}=Symbol[])
    if isempty(cols)
        cols = names(D)
    end
    for (c, T) in zip(cols, target_types)
        D[c] = map(x->convert(T, x), D[c])
    end
    D
end

function convert_to_array_cols!(D::DataFrame)
    for i = 1:length(D.columns)
        D.columns[i] = convert(Array, D.columns[i])
    end
end

function find_in_col{T}(D::DataFrame, src_col::Union{Symbol,Int64}, 
    target_col::Union{Symbol,Int64}, src_val::T)
    ind = find(D[src_col] .== src_val)
    x = D[ind[1], target_col] #if there are multiple matches, take the first
    x
end

join_all(Ds::AbstractDataFrame...; kwargs...) = join_all([d for d in Ds]; kwargs...)
function join_all{T<:AbstractDataFrame}(Ds::AbstractVector{T}; kwargs...)
    d = Ds[1]
    for i = 2:length(Ds)
        d = join(d, Ds[i]; kwargs...)
    end
    d
end

abstract PadMethod
immutable FillPad <: PadMethod
    vec::Vector{Any}
end
ZeroPad(d::DataFrame) = FillPad(zero.(eltypes(d)))
immutable RepeatLastPad <: PadMethod end

function pad!(p::FillPad, d::DataFrame, nrows::Int)
    while nrow(d) < nrows
        push!(d, p.vec)
    end
end
function pad!(p::RepeatLastPad, d::DataFrame, nrows::Int)
    row = convert(Array, d[end, :])
    while nrow(d) < nrows
        push!(d, row)
    end
end

function names_by_type(D::DataFrame)
    d = Dict{Type,Vector{Symbol}}()
    for (nam, typ) in zip(names(D), eltypes(D))
        if !haskey(d, typ)
            d[typ] = [nam]
        else
            push!(d[typ], nam)
        end
    end
    d
end

function names_by_type(D::DataFrame, typ::Type)
    i = find(typ .== eltypes(D))
    return names(D)[i]
end

end #module
