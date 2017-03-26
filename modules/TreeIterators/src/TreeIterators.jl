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
Deprecated: Use AbstractTrees.jl instead (depends on a slightly different interface)
Iterator for tree structures, depth-first traversal
"""
module TreeIterators 

export tree_iter, traverse

get_children(node) = error("user should override get_children().  Takes
    a node object and returns an iterable of children") 

type TreeIt
    opennodes::Vector{Any}
end

tree_iter(root) = TreeIt([root])

Base.start(iter::TreeIt) = 0 
Base.next(iter::TreeIt, state) = (expand!(iter), state) 

function expand!(iter::TreeIt)
    node = pop!(iter.opennodes) 
    children = get_children(node) #implemented by user
    for child in reverse(children)
        push!(iter.opennodes, child)
    end
    node
end

Base.done(iter::TreeIt, state) = isempty(iter.opennodes)

#workaround: iterator traits on v0.5 for collect(), not needed for v0.4
if VERSION >= v"0.5.0-dev+3305"
    Base.iteratorsize(iter::TreeIt) = Base.SizeUnknown() 
end

"""
Traverse tree, apply f at each node, combine the results using op.
"""
function traverse(f::Function, op::Function, node)
    v = f(node) 
    for child in get_children(node)
        v = op(v, traverse(f, op, child)) 
    end
    v
end
end #module
