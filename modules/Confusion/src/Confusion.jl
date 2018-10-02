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

module Confusion

export ConfusionMat, ConfusionIndices
export truepos, trueneg, falsepos, falseneg 
export truepos_indices, trueneg_indices, falsepos_indices, falseneg_indices
export recall, accuracy, f1_score

import Base.precision

type ConfusionMat
    truepos::Int64
    trueneg::Int64
    falsepos::Int64
    falseneg::Int64
end

type ConfusionIndices
    truepos::Vector{Int64}
    trueneg::Vector{Int64}
    falsepos::Vector{Int64}
    falseneg::Vector{Int64}
end

"""
Confusion matrix metrics for a binary classifier
returns a dictionary with entries ASCIIString[truepos,trueneg,falsepos,falseneg]
truepos means you predicted positive and you were correct
trueneg means you predicted negative and you were correct
falsepos means you predicted positive and you were incorrect
falseneg means you predicted negative and you were incorrect
"""
function ConfusionMat(pred::AbstractVector{Bool}, truth::AbstractVector{Bool})
    ConfusionMat( 
        truepos(pred, truth),
        trueneg(pred, truth),
        falsepos(pred, truth),
        falseneg(pred, truth) 
        )
end

"""
Same as confusion but returns the corresponding indices
"""
function ConfusionIndices(pred::AbstractVector{Bool}, truth::AbstractVector{Bool})
    ConfusionIndices(
        truepos_indices(pred, truth),
        trueneg_indices(pred, truth),
        falsepos_indices(pred, truth),
        falseneg_indices(pred, truth) 
        )
end

function precision(m::ConfusionMat)
    m.truepos / (m.truepos + m.falsepos)
end

function recall(m::ConfusionMat)
    m.truepos / (m.truepos + m.falseneg)
end

function accuracy(m::ConfusionMat)
    (m.truepos + m.trueneg) / (m.truepos + m.falsepos + m.trueneg + m.falseneg)
end

function f1_score(m::ConfusionMat)
    (2*m.truepos) / (2*m.truepos + m.falsepos + m.falseneg)
end

"pred=1, truth=1"
truepos(pred::AbstractVector{Bool}, truth::AbstractVector{Bool}) = count(identity, pred[find(truth)])
"pred=0, truth=0"
trueneg(pred::AbstractVector{Bool}, truth::AbstractVector{Bool}) = count(!, pred[find(!, truth)])
"pred=1, truth=0"
falsepos(pred::AbstractVector{Bool}, truth::AbstractVector{Bool}) = count(identity, pred[find(!, truth)])
"pred=0, truth=1"
falseneg(pred::AbstractVector{Bool}, truth::AbstractVector{Bool}) = count(!, pred[find(truth)])

"pred=1, truth=1"
truepos_indices(pred::AbstractVector{Bool}, truth::AbstractVector{Bool}) = find(x->x[1] && x[2], collect(zip(pred,truth))) 
"pred=0, truth=0"
trueneg_indices(pred::AbstractVector{Bool}, truth::AbstractVector{Bool}) = find(x->!x[1] && !x[2], collect(zip(pred,truth)))
"pred=1, truth=0"
falsepos_indices(pred::AbstractVector{Bool}, truth::AbstractVector{Bool}) = find(x->x[1] && !x[2], collect(zip(pred,truth)))
"pred=0, truth=1"
falseneg_indices(pred::AbstractVector{Bool}, truth::AbstractVector{Bool}) = find(x->!x[1] && x[2], collect(zip(pred,truth)))


end #module

