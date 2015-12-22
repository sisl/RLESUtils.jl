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

using RLESUtils.Loggers
using RLESUtils.Observers
using Base.Test

function test_dflogger()
  logger = DataFrameLogger([Bool,Int], ["mybool", "myint"])
  logger.f([true, 0])
  logger.f([false, 5])
  d = get_log(logger)
  @test d[:mybool] == [true, false]
  @test d[:myint] == [0, 5]

  #test operability with Observers
  empty!(logger)
  obs = Observer()
  add_observer(obs, logger.f)
  notify_observer(obs, [false, 150])
  notify_observer(obs, [true, -5])
  d = get_log(logger)
  @test d[:mybool] == [false, true]
  @test d[:myint] == [150, -5]
end

function test_arraylogger()
  logger = ArrayLogger()
  logger.f([true, 0])
  logger.f([false, 5])
  d = get_log(logger)
  @test d[1] == [true, 0]
  @test d[2] == [false, 5]

  #test operability with Observers
  empty!(logger)
  obs = Observer()
  add_observer(obs, logger.f)
  notify_observer(obs, [false, 150])
  notify_observer(obs, [true, -5])
  d = get_log(logger)
  @test d[1] == [false, 150]
  @test d[2] == [true, -5]
end

test_dflogger()
test_arraylogger()
