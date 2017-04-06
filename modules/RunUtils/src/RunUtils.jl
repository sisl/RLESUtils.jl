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
Spawn new julia sessions and execute code in parallel.  will only run up
to number of procs available and automatically spawn the next task.
Example usage:
addprocs(2)
src_array = JuliaSource[ JuliaSource("using MyModule1; myfunc1()"), 
JuliaSource("using MyModule2; myfunc2()")]
pmap(julia_process, src_array)
Note: To work properly, create a symlink to this module in your julia pkg folder
"""
module RunUtils

export JuliaSource, julia_process

import Compat.ASCIIString

immutable JuliaSource
    src::ASCIIString
end

function julia_process(lst::Vector{JuliaSource}, np::Int64)
    julia_exe = Base.julia_cmd()
    n = length(lst)
    results = Vector{Any}(n)
    i = 1
    nextidx() = (idx=i; i+=1; idx)
    @sync begin
        for p=1:np
            @async begin
                while true
                    idx = nextidx()
                    if idx > n
                        break
                    end
                    src = lst[idx].src
                    outfile = tempname()
                    println("$idx: $outfile")
                    msg = "success"
                    try
                        run(pipeline(`$julia_exe -e $src`, stdout=outfile))
                    catch e
                        msg = e
                    end
                    println("$idx: $msg")
                    results[idx] = outfile 
                end
            end
        end
    end
    results
end

end #module
