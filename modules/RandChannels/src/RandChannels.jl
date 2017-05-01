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
Pre-allocated random samples organized into channels.
Primary use case is to enable threaded random number generation to have the same
deterministic outcome as sequential version.  Each loop iteration draws numbers from 
its own channel, which allows random and out of order computations.
See runtests.jl for example usage.
"""
module RandChannels

export RandChannel, WrappedRandChannel, resample!, set_channel!

import Base.rand

type RandChannel{T}
    channels::Vector{Vector{T}} 
    indices::Vector{Int64}

end
function RandChannel{T}(rng::AbstractRNG, num_channels::Int64, 
    channel_length::Int64, ::Type{T}=Float64) 
    channels = [rand(T, channel_length) for i=1:num_channels]
    indices = ones(Int64, num_channels)
    RandChannel(channels, indices)
end
function RandChannel{T}(num_channels::Int64, channel_length::Int64, ::Type{T}=Float64) 
    RandChannel(Base.GLOBAL_RNG, num_channels, channel_length, T)
end

function rand(rc::RandChannel, channel_number::Int64)
    index = rc.indices[channel_number]
    r = rc.channels[channel_number][index]
    rc.indices[channel_number] = index + 1 
    r
end

function resample!{T}(rc::RandChannel{T})
    @inbounds for i = 1:length(rc.channels)
        ch = rc.channels[i]
        @inbounds for j = 1:length(ch)
            ch[j] = rand(T)
        end
    end
    fill!(rc.indices, 1)
    rc
end

type WrappedRandChannel{T} <: AbstractRNG
    rc::RandChannel{T}
    channel_number::Int64
end

function set_channel!(wrc::WrappedRandChannel, channel_number::Int64) 
    wrc.channel_number = channel_number
end

rand(wrc::WrappedRandChannel) = rand(wrc.rc, wrc.channel_number)

end #module
