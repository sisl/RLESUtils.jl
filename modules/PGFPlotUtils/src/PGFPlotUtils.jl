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

module PGFPlotUtils

export plot_tikz
export histogram_all_cols, histogram_all_cols_sbs 

using DataFrames
using TikzPictures
using RLESUtils, MathUtils
import PGFPlots
import PGFPlots: Plots, Axis, GroupPlot

"""
Histogram every column of a dataframe
"""
function histogram_all_cols(D::DataFrame; 
    discretization::Symbol=:default,
    format::Symbol=:TEXPDF)

    td = TikzDocument()
    for (sym, col) in eachcol(D) 
        col = convert(Array, col)
        ax = Axis(Plots.Histogram(col, discretization=discretization), ymin=0,
            title=string(sym))
        tp = PGFPlots.plot(ax)
        push!(td, tp)
    end
    td
end

"""
Histogram column-wise to compare dataframes.  Side-by-side plots. 
"""
function histogram_all_cols_sbs(Ds::DataFrame...; 
    datanames::Array{String}=String[],
    discretization::Symbol=:default,
    format::Symbol=:TEXPDF)

    N = length(Ds)
    if isempty(datanames)
        resize!(datanames, N)
        for i = 1:N
            datanames[i] = "Dataset $i"
        end
    end

    td = TikzDocument()
    for sym in names(Ds[1]) 
        g = GroupPlot(N, 1, groupStyle="horizontal sep = 1cm")
        for i = 1:N
            col = convert(Array, Ds[i][sym])
            ax = Axis(Plots.Histogram(col, discretization=discretization), ymin=0, 
                title=string(datanames[i]))
            push!(g, ax)
        end
        tp = PGFPlots.plot(g)
        push!(td, tp, caption=string(sym))
    end
    td
end

function plot_tikz(fileroot::AbstractString, tikz::Union{TikzPicture,TikzDocument}, 
    format::Symbol=:TEXPDF)
    plot_tikz(fileroot, tikz, Val{format})
end

#Workaround, currently it is not possible to get both TEX and PDF files in one call.  
#Using the keep aux file option keeps the tex file, but also keeps all the 
#other intermediate files.
function plot_tikz(fileroot::AbstractString, tikz::Union{TikzPicture,TikzDocument}, 
    ::Type{Val{:TEXPDF}})
    TikzPictures.save(PDF(fileroot), tikz)
    TikzPictures.save(TEX(fileroot), tikz)
end
function plot_tikz(fileroot::AbstractString, tikz::Union{TikzPicture,TikzDocument}, 
    ::Type{Val{:PDF}})
    TikzPictures.save(PDF(fileroot), tikz)
end
function plot_tikz(fileroot::AbstractString, tikz::Union{TikzPicture,TikzDocument}, 
    ::Type{Val{:TEX}})
    TikzPictures.save(TEX(fileroot), tikz)
end
function plot_tikz(fileroot::AbstractString, tikz::Union{TikzPicture,TikzDocument}, ::Any)
    error("plot_tikz: Type not supported!")
end

end #module
