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

module DataFrameSets

export DFSet, DFSetLabeled, colnames, setlabels, setlabels!, load_dir, load_csvs, anyna, save_csvs, writemeta, metacolnames, recordcolnames, filenames
export getmeta, getrecords, labels, metadf, getmeta_array, getdata, reset_ids!
export addrecord!

import Base: start, next, done, length, size, vcat, getindex, convert
import Base: maximum, minimum

using RLESUtils, FileUtils
using Reexport
@reexport using DataFrames
import DataArrays.anyna

const METAFILE = "_META.csv.gz"
# metafile is a dataframe that contains:
# required columns, one row for each record
# :id that matches row number (for joins and reverse lookup)

type DFSet
    meta::DataFrame
    records::Vector{DataFrame}
end
DFSet(meta::DataFrame, record::DataFrame) = DFSet(meta, [record])
DFSet(records::Array{DataFrame}) = DFSet(metadf(length(records)), records)
DFSet() = DFSet(metadf(), DataFrame[])

function metadf(N::Int64=0)
    meta = DataFrame()
    meta[:id] = 1:N
    meta
end

function load_csvs(dir::AbstractString)
    metafile = joinpath(dir, METAFILE)
    if isfile(metafile) #look for metafile
        meta = readtable(metafile)
    else
        error("load_csvs: metafile not found!")
    end
    fnames = filenames(meta; dir=dir)
    Ds = DFSet(meta, map(readtable, fnames))
    Ds
end

function writemeta(outdir::AbstractString, meta::DataFrame)
    mkpath(outdir)

    fname = joinpath(outdir, METAFILE)
    writetable(fname, meta)
end

function save_csvs(outdir::AbstractString, Ds::DFSet)
    mkpath(outdir)

    #meta file
    writemeta(outdir, getmeta(Ds))

    #records
    fnames = filenames(Ds; dir=outdir)
    records = getrecords(Ds) 
    for i = 1:length(Ds)
        writetable(fnames[i], records[i])
    end
end

metacolnames(Ds::DFSet) = colnames(Ds.meta)
recordcolnames(Ds::DFSet) = colnames(Ds.records[1])
colnames(D::DataFrame) = map(string, names(D))

getindex(Ds::DFSet, inds) = DFSet(Ds.meta[inds,:], Ds.records[inds])

filenames(Ds::DFSet; dir::AbstractString="") = filenames(Ds.meta; dir=dir)
filenames(Ds::DFSet, inds; dir::AbstractString="") = filenames(Ds.meta, inds; dir=dir)
function filenames(meta::DataFrame; dir::AbstractString="") 
    fs = convert(Array, meta[:id])
    fs = map(f -> joinpath(dir, string(f,".csv.gz")), fs)
    fs
end
function filenames(meta::DataFrame, inds; dir::AbstractString="") 
    fs = convert(Array, meta[inds, :id])
    fs = map(f -> joinpath(dir, string(f, ".csv.gz")), fs)
    fs
end

getmeta(Ds::DFSet) = Ds.meta
getrecords(Ds::DFSet) = Ds.records
getmeta(Ds::DFSet, inds) = Ds.meta[inds,:]
getmeta_array(Ds::DFSet, inds) = squeeze(convert(Array, getmeta(Ds,inds)), 1)
getrecords(Ds::DFSet, inds) = Ds.records[inds]

reset_ids!(Ds::DFSet) = Ds.meta[:id] = 1:nrow(Ds.meta)

function addrecord!{T}(Ds::DFSet, record::DataFrame, row::Vector{T}=Any[])
    id = length(Ds) + 1
    push!(Ds.meta, [id; row])
    push!(Ds.records, record)
end

start(Ds::DFSet) = 1 
next(Ds::DFSet, i::Int64) = ((getmeta_array(Ds, i), getrecords(Ds, i)), i + 1)
done(Ds::DFSet, i::Int64) = i > length(Ds) 
length(Ds::DFSet) = length(Ds.records) #number of records

function vcat(D1::DFSet, D2::DFSet)
    DFSet(
      vcat(D1.meta, D2.meta),
      vcat(D1.records, D2.records)
      )
end

anyna(Ds::DFSet) = anyna(Ds.records)
anyna(Ds::Vector{DataFrame}) = any(map(anyna, Ds))
anyna(D::DataFrame) = any(convert(Array, map(anyna, eachcol(D))))

"""
returns the size of each record
if check is true, then check that all records have the same size
else just return the size of the first one and assume it's correct
"""
function size(Ds::DFSet; check::Bool=false)
    recs = getrecords(Ds)
    ndat = length(recs)
    nr = nrow(recs[1])
    nc = ncol(recs[1])

    if check
        for i = 1:length(recs)
            if nr != nrow(recs[i])
                println("row mismatch at $i")
                @assert false
            end
            if nc != ncol(recs[i])
                println("column mismatch at $i")
                @assert false
            end
        end
    end
    (ndat, nr, nc)
end

"""
Convert DFSet to a 3D array
"""
function convert(::Type{Array}, Ds::DFSet)
    recs = getrecords(Ds)
    A1 = convert(Array, recs[1]) #use first one to get eltype
    A = Array(eltype(A1), size(Ds)) #3D array
    A[1,:,:] = A1 #reuse the first one
    for i = 2:length(recs)
        A[i,:,:] = convert(Array, recs[i])
    end
    A 
end

function maximum(Ds::DFSet, col::Symbol)
    maximum(map(D->maximum(D[col]), getrecords(Ds)))
end

function minimum(Ds::DFSet, col::Symbol)
    minimum(map(D->minimum(D[col]), getrecords(Ds)))
end

### DFSetLabeled
type DFSetLabeled{T}
    data::DFSet
    labels::Vector{T}
end

DFSetLabeled(Ds::DFSet, labels::DataArray) = DFSetLabeled(Ds, convert(Array, labels))
function DFSetLabeled(Ds::DFSet, metacolumn::Symbol; transform::Function=identity)
    meta = getmeta(Ds)
    labels = convert(Array, meta[metacolumn])
    labels = map(transform, labels)
    Dl = DFSetLabeled(Ds, labels)
    Dl
end

function getindex{T}(Dl::DFSetLabeled{T}, inds) 
    out = DFSetLabeled(Dl.data[inds], Dl.labels[inds])
    out
end

getmeta(Dl::DFSetLabeled) = getmeta(Dl.data)
getrecords(Dl::DFSetLabeled) = getrecords(Dl.data)
labels(Dl::DFSetLabeled) = Dl.labels
getmeta(Dl::DFSetLabeled, inds) = getmeta(Dl.data, inds)
getmeta_array(Dl::DFSetLabeled, inds) = getmeta_array(Dl.data, inds)
getrecords(Dl::DFSetLabeled, inds) = getrecords(Dl.data, inds)
labels(Dl::DFSetLabeled, inds) = Dl.labels[inds]
getdata(Dl::DFSetLabeled) = Dl.data

reset_ids!(Dl::DFSetLabeled) = reset_ids!(Dl.data) 

"""
set labels, same type as existing
"""
function setlabels!{T}(Dl::DFSetLabeled{T}, labels::Vector{T})
    @assert length(Dl.data) == length(labels)
    Dl.labels = labels
    Dl
end

"""
set labels, different type as existing
"""
function setlabels{T1, T2}(Dl::DFSetLabeled{T1}, labels::Vector{T2})
    @assert length(Dl.data) == length(labels)
    Dl = DFSetLabeled{T2}(Dl.data, labels)
    Dl
end

function addrecord!{Tl,Tr}(Dl::DFSetLabeled{Tl}, record::DataFrame, 
    label::Tl, row::Vector{Tr}=Any[])

    addrecord!(Dl.data, record, row)
    push!(Dl.labels, label)
end

"""
returns the size of each record
if check is true, then check that all records have the same size
else just return the size of the first one and assume it's correct
"""
function size(Dl::DFSetLabeled; check::Bool=false)
    size(Dl.data; check=check)
end

anyna(Dl::DFSetLabeled) = anyna(Dl.data)

start(Dl::DFSetLabeled) = 1 
next(Dl::DFSetLabeled, i::Int64) = ((getmeta_array(Dl,i), getrecords(Dl,i), labels(Dl,i)), i + 1)
done(Dl::DFSetLabeled, i::Int64) = i > length(Dl) 
length(Dl::DFSetLabeled) = length(Dl.data) #number of records

function vcat{T}(Dl1::DFSetLabeled{T}, Dl2::DFSetLabeled{T})
    DFSetLabeled(
      vcat(Dl1.data, Dl2.data),
      vcat(Dl1.labels, Dl2.labels)
      )
end

maximum(Dl::DFSetLabeled, col::Symbol) = maximum(Dl.data, col)
minimum(Dl::DFSetLabeled, col::Symbol) = minimum(Dl.data, col)

end #module
