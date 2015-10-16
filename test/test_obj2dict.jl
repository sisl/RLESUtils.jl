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

using RLESUtils.Obj2Dict

using Base.Test

type MySubType
  p::Int64
  q::String
end
MySubType() = MySubType(0,"0")
==(x::MySubType, y::MySubType) = x.p == y.p && x.q == y.q

type MyType
  a::Int64
  b::String
  c::MySubType
end
MyType() = MyType(0,"0",MySubType())
==(x::MyType, y::MyType) = x.a == y.a && x.b == y.b && x.c == y.c

type MyTypeArray
  a::Int64
  b::String
  c::Array{MySubType}
end
MyTypeArray() = MyTypeArray(0,"0",[MySubType() for i=1:2])
==(x::MyTypeArray, y::MyTypeArray) = x.a == y.a && x.b == y.b && x.c == y.c

function test1(; verbose::Bool = false)
  # Test custom subtypes
  x = MyType(1,"2",MySubType(1,"2"))
  verbose ? println("x = $x") : nothing

  d = Obj2Dict.to_dict(x)
  verbose ? println("d = $d") : nothing

  y = Obj2Dict.to_obj(d)
  verbose ? println("y = $y") : nothing

  @test x == y
  return (x, d, y)
end

function test2(; verbose::Bool = false)
  # Test arrays
  x = [MyType(i,"$j",MySubType(i,"$j")) for i = 1:2, j=1:2]
  verbose ? println("x = $x") : nothing

  d = Obj2Dict.to_dict(x)
  verbose ? println("d = $d") : nothing

  y = Obj2Dict.to_obj(d)
  verbose ? println("y = $y") : nothing

  @test x == y
  return (x, d, y)
end

function test3(; verbose::Bool = false)
  # Test array as member
  x = MyTypeArray(1,"2", [MySubType(i,"$j") for i = 1:2, j=1:2])
  verbose ? println("x = $x") : nothing

  d = Obj2Dict.to_dict(x)
  verbose ? println("d = $d") : nothing

  y = Obj2Dict.to_obj(d)
  verbose ? println("y = $y") : nothing

  @test x == y
  return (x, d, y)
end

test1()
test2()
test3()
