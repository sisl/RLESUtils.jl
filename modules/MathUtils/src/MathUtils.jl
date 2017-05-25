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

export scale01, to_plusminus_b, to_plusminus_pi, to_plusminus_180, quantize, 
    gini_impurity, gini_from_counts,
    round_nearest_even, round_nearest_odd,
    angle_diff_deg, angle_diff_rad
export entropy_from_vec, entropy_from_counts
export SEM, SEM_ymax, SEM_ymin
export sum_to_1
export logxpy
export round_up_to_multiple

using StatsBase

import Base: extrema, clamp!

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

function quantize(x::AbstractFloat, b::AbstractFloat)
  # quantize x to the nearest multiple of b
  d, r = divrem(x, b)
  return b * (d + round(r / b))
end

"""
Computes the upper error bar in standard error of the mean
"""
function SEM_ymax{T}(ys::AbstractVector{T})
    ymax = mean(ys) + SEM(ys)
    ymax
end

"""
Computes the lower error bar in standard error of the mean
"""
function SEM_ymin{T}(ys::AbstractVector{T})
    ymin = mean(ys) - SEM(ys)
    ymin
end

"""
Computes the standard error of the mean
"""
function SEM{T}(ys::AbstractVector{T})
    s = std(ys)
    sem = isnan(s) ? zero(T) : s / sqrt(length(ys))
    sem
end

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

sum_to_1(v::Vector{Float64}) = v ./ sum(v)

"""
Compute log(x+y) from log(x) and log(y). Exponentiates safely by first sorting and
uses identity log(x+y) = log(x) + log(1+y/x)
"""
function logxpy(logx::Float64, logy::Float64)
  if logx == logy == -Inf #special case where identity breaks down
    return -Inf
  end
  if logx < logy
    logy, logx = logx, logy #swap so that logx is bigger
  end
  @assert logx >= logy
  r = exp(logy - logx) #r = x/y, or log(r) = log(x/y), exponentiating is safe since r in [0,1]
  logz = logx + log1p(r)
  logz #where z = x+y, or log(z) = log(x+y)
end

"""
Vector version of logxpy(logx,logy)
"""
function logxpy(logX::Vector{Float64})
  logz, maxindex = findmax(logX) #avoid swapping
  if logz == -Inf #detect special case and end early
    return -Inf
  end
  for i = 1:maxindex - 1
    logz = logxpy(logz, logX[i])
  end
  #skip over maxindex
  for i = (maxindex + 1):length(logX)
    logz = logxpy(logz, logX[i])
  end
  logz
end

round_nearest_odd(x::Float64) = 2.*round(Int64, (x+1)/2)-1
round_nearest_even(x::Float64) = 2.*round(Int64, x/2)

"""
returns x-y where angles are in degrees, handles wraparound
"""
function angle_diff_deg(x::Float64, y::Float64) 
    a = x - y
    mod(a + 180.0, 360.0) - 180.0
end

"""
returns x-y where angles are in radians, handles wraparound
"""
function angle_diff_rad(x::Float64, y::Float64) 
    a = x - y
    mod(a + pi, 2pi) - pi 
end

function entropy_from_vec{T}(v::AbstractVector{T})
  cnts = isempty(v) ? Int64[] : counts(v)
  ent = entropy_from_counts(cnts)
  ent
end

function entropy_from_vec{T}(v1::AbstractVector{T}, v2::AbstractVector{T})
  cnts1 = isempty(v1) ? Int64[] : counts(v1)
  cnts2 = isempty(v2) ? Int64[] : counts(v2)
  ent = entropy_from_counts(cnts1, cnts2)
  ent
end

function entropy_from_counts(cnts::AbstractVector{Int64})
  N = sum(cnts)
  ent = (N == 0) ? 0.0 : entropy(cnts / N)
  ent
end

function entropy_from_counts(cnts1::AbstractVector{Int64}, cnts2::AbstractVector{Int64})
  n1 = sum(cnts1)
  n2 = sum(cnts2)
  N = n1 + n2
  if N == 0
    return ent = 0.0
  end
  ent1 = entropy_from_counts(cnts1)
  ent2 = entropy_from_counts(cnts2)
  ent = (n1 * ent1 + n2 * ent2) / N
  ent
end

"""
Rounds x up to the nearest integer multiple of b
"""
function round_up_to_multiple(x::Int64, b::Int64)
    round(Int64, x / b) * b
end

function clamp!{T}(x::AbstractVector{Float64}, limits::AbstractVector{{Tuple{T,T}})
    for i = 1:length(theta)
        x[i] = clamp(x[i], limits[i][1], limits[i][2])
    end
end

end #module
