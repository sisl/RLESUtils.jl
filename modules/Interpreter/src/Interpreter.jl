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
Evaluates an expression without compiling it.
Uses AST and symbol lookups. Only supports :call and :(=) 
expressions at the moment.
Example:
tab = SymbolTable(:f => f, :x => x)
ex = :(f(x))
interpret(tab, ex)
"""
module Interpreter

export SymbolTable, interpret

typealias SymbolTable Dict{Symbol,Any}

interpret(tab::SymbolTable, x::Any) = x
interpret(tab::SymbolTable, s::Symbol) = tab[s]

function interpret(tab::SymbolTable, ex::Expr)
    interpret(tab, ex, Val{ex.head})
end
function interpret(tab::SymbolTable, ex::Expr, ::Type{Val{:call}})
    f = tab[ex.args[1]]
    args = [interpret(tab,ex.args[i]) for i = 2:endof(ex.args)]
    result = f(args...)
    result
end
function interpret(tab::SymbolTable, ex::Expr, ::Type{Val{:(=)}})
    tab[ex.args[1]] = interpret(tab, ex.args[2]) #assignments done to symboltable
end
function interpret(tab::SymbolTable, ex::Expr, ::Type{Val{:block}})
    result = nothing
    for x in ex.args
        result = interpret(tab, x)
    end
    result
end
function interpret(tab::SymbolTable, ex::Expr, x)
    error("Expression type not supported")
end

end #module
