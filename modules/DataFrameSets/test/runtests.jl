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

using RLESUtils, DataFrameSets, DataFrames
using Base.Test

dfs = DFSet()

#add some records
addrecord!(dfs, DataFrame([1 2; 3 4])) 
addrecord!(dfs, DataFrame([5 6; 7 8])) 

#add some meta info
meta = getmeta(dfs)
meta[:name] = ["a1", "b2"]

#make sure add was done correctly
@test convert(Array, getmeta(dfs)) == [1 "a1"; 2 "b2"]
@test convert(Array, getrecords(dfs, 1)) == [1 2; 3 4]

#test misc getters
@test metacolnames(dfs) == ["id", "name"]
@test recordcolnames(dfs) == ["x1", "x2"]
@test length(dfs) == 2
@test anyna(dfs) == false 
@test filenames(dfs) == ["1.csv.gz", "2.csv.gz"]

#test iterator
A = collect(dfs)
@test A[1][1] == [1, "a1"]
@test A[1][2] == DataFrame([1 2 ; 3 4])
@test A[2][1] == [2, "b2"]
@test A[2][2] == DataFrame([5 6; 7 8])


#test getindex
@test convert(Array, getmeta(dfs[1])) == [1 "a1"]
@test convert(Array, getrecords(dfs[1],1)) == [1 2; 3 4]

#test DFSetLabled
dl = DFSetLabeled(dfs, [true, false])

@test length(dl) == 2
@test labels(dl) == [true, false]
@test convert(Array, getrecords(dl)) == convert(Array, getrecords(dfs))
@test getmeta(dl) == getmeta(dl)

#test iterator
A = collect(dl)
@test A[1][1] == [1, "a1"]
@test A[1][2] == DataFrame([1 2 ; 3 4])
@test A[1][3] == true
@test A[2][1] == [2, "b2"]
@test A[2][2] == DataFrame([5 6; 7 8])
@test A[2][3] == false

#test alternate constructor
dl2 = DFSetLabeled(dfs, :id)

@test labels(dl2) == [1, 2]
