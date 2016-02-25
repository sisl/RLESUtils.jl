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

module MathUtils

export scale01, to_plusminus_b, to_plusminus_pi, to_plusminus_180, gini_impurity, gini_from_counts

using StatsBase

import Base.extrema

function extrema{T}(A::Array{T,2}, dim)
  mapslices(A, dim) do x
    extrema(x)
  end
end

function scale01(x::Real, xmin::Real, xmax::Real)
  x = min(xmax, max(x, xmin)) #capped to be within [xmin,xmax]
  return (x - xmin) / (xmax - xmin)
end

#mods x to the range [-b, b]
function to_plusminus_b(x::AbstractFloat, b::AbstractFloat)
  z = mod(x, 2 * b)
  return (z > b) ? (z - 2 * b) : z
end
to_plusminus_pi(x::AbstractFloat) = to_plusminus_b(x, float(pi))
to_plusminus_180(x::AbstractFloat) = to_plusminus_b(x, 180.0)

function gini_impurity{T}(v::AbstractVector{T})
  cnts = isempty(v) ? Int64[] : counts(v)
  gini = gini_from_counts(cnts)
  gini
end

function gini_impurity{T}(v1::AbstractVector{T}, v2::AbstractVector{T})
  cnts1 = isempty(v1) ? Int64[] : counts(v1)
  cnts2 = isempty(v2) ? Int64[] : counts(v2)
  gini = gini_from_counts(cnts1, cnts2)
  gini
end

function gini_from_counts(cnts::AbstractVector{Int64})
  N = sum(cnts)
  if N == 0
    return gini = 0.0
  end
  gini = 1.0 - sumabs2(cnts / N)
  gini
end

function gini_from_counts(cnts1::AbstractVector{Int64}, cnts2::AbstractVector{Int64})
  n1 = sum(cnts1)
  n2 = sum(cnts2)
  N = n1 + n2
  if N == 0
    return gini = 0.0
  end
  g1 = gini_from_counts(cnts1)
  g2 = gini_from_counts(cnts2)
  gini = (n1 * g1 + n2 * g2) / N
  gini
end

end #module
