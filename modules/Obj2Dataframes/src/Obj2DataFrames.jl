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
Convert a composite object of primitives to a DataFrame. Can load them back
Example use case: save parameter objects with Loggers
"""
module Obj2DataFrames

export ObjDataFrame, eltypes, set!, to_df, to_args

using DataFrames

import DataFrames: eltypes
import Base: convert, values 

type ObjDataFrame
    d::DataFrame
end

to_df{T}(x::T) = convert(DataFrame, convert(ObjDataFrame, x))
to_args{T}(d::DataFrame) = values(ObjDataFrame(d))

convert(::Type{DataFrame}, obj::ObjDataFrame) = obj.d

eltypes(obj::ObjDataFrame) = eltypes(obj.d)

function convert{T}(::Type{ObjDataFrame}, x::T)
    fields = fieldnames(x)
    types = map(f->fieldtype(T, f), fields)
    vals = map(f->getfield(x, f), fields)
    obj = ObjDataFrame(DataFrame(types, fields,0))
    push!(obj.d, vals)
    obj
end

function set!{T}(x::T, obj::ObjDataFrame)
    for nm in names(obj.d)
        setfield!(x, nm, obj.d[1, nm]) 
    end
end

function values(obj::ObjDataFrame)
   [obj.d[1,i] for i = 1:ncol(obj.d)]
end

end #module
