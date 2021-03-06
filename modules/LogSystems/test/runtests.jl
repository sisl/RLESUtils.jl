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

using RLESUtils, LogSystems, Observers, Loggers
using Base.Test

function test1()
    #package side
    logsys = LogSystem()
    register_log!(logsys, "iter", ["i"], [Int64])
    register_log!(logsys, "val", ["x", "2x"], [Float64, Float64])
    register_log!(logsys, "unused", ["y"], [Float64])
    register_log!(logsys, "prod", ["x^2"], [Float64], "val", v->[v[1]*v[1]])
    register_log!(logsys, "userparam", ["n*x"], [Float64], "val", v->[logsys.params["n"]*v[1]])

    #user side
    register_log!(logsys, "sum", ["x+2x"], [Float64], "val", v->[v[1]+v[2]]) #user custom log
    logsys.params["n"] = 5
    logs = TaggedDFLogger()
    send_to!(logs, logsys, ["iter", "val", "sum", "prod", "userparam"])
    send_to!(STDOUT, logsys, ["iter", "sum"]) 
    send_to!(STDOUT, logsys, "iter"; interval=2)
    send_to!(STDOUT, logsys, "val", v->"sum(v1,v2)=$(round(v[1]+v[2], 2))")

    #package side
    observer = get_observer(logsys)
    for i = 1:10
        @notify_observer(observer, "iter", [i])

        x = i
        @notify_observer(observer, "val", [x, 2x])
    end
     
    #user side
    #save_logs(logs)

    logs
end
