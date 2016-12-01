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
Example usage:
#package side
logsys = LogSystem()
register_log!(logsys, ...) #define logs
#user side
list_logs(logsys)
logs = TaggedDFLogger()
send_to!(STDOUT, logsys, ...) #output a log to console 
send_to!(logs, logsys, ...) #output a log to logger
"""
module LogSystems

export LogDB, LogSystem, list_logs, get_observer, register_log!, send_to!, empty_listeners!

import Compat.ASCIIString
import Base: clear!

using RLESUtils, Observers, Loggers

typealias NamesMap Dict{ASCIIString,Vector{ASCIIString}}
typealias TypesMap Dict{ASCIIString,Vector{DataType}}
typealias NameMap Dict{ASCIIString,ASCIIString}
typealias FuncMap Dict{ASCIIString,Function}
typealias Vars Dict{ASCIIString,Any}

type LogDB
    var_names::NamesMap
    var_types::TypesMap
    obs_names::NameMap
    f::FuncMap
end
LogDB() = LogDB(NamesMap(), TypesMap(), NameMap(), FuncMap())

type LogSystem
    db::LogDB
    params::Vars
    observer::Observer
end
LogSystem() = LogSystem(LogDB(), Vars(), Observer())

get_observer(logsys::LogSystem) = logsys.observer
empty_listeners!(logsys::LogSystem) = empty!(logsys.observer)

function clear!(logsys::LogSystem)
    empty!(logsys.db.var_names)
    empty!(logsys.db.var_types)
    empty!(logsys.db.obs_names)
    empty!(logsys.db.f)
    empty!(logsys.observer)
end

"""
Register a log with the system to make it available for users, with custom
"""
function register_log!{S<:AbstractString}(logsys::LogSystem, log_name::AbstractString,
    var_names::Vector{S}, var_types::Vector{DataType}, obs_name::AbstractString,
    f::Function=identity)
    logsys.db.var_names[log_name] = var_names
    logsys.db.var_types[log_name] = var_types
    logsys.db.obs_names[log_name] = obs_name
    logsys.db.f[log_name] = f
end
"""
Register a log with the system to make it available for users
"""
function register_log!{S<:AbstractString}(logsys::LogSystem, log_name::AbstractString,
    var_names::Vector{S}, var_types::Vector{DataType})
    logsys.db.var_names[log_name] = var_names
    logsys.db.var_types[log_name] = var_types
end

function list_logs(logsys::LogSystem)
    collect(keys(logsys.db.var_names))
end

function processing_func(logsys::LogSystem, log_name::AbstractString)
    obs_name = get(logsys.db.obs_names, log_name, log_name)
    f = get(logsys.db.f, log_name, identity)
    (obs_name, f)
end

"""
List a number of logs to listen to, and send them to IO using canned format
"""
function send_to!{S<:AbstractString}(io::IO, logsys::LogSystem, log_names::Vector{S}) 
    for log_name in log_names
        send_to!(io, logsys, log_name)
    end
end
function send_to!(io::IO, logsys::LogSystem, log_name::AbstractString; interval::Int64=1) 
    ct = cycle((interval-1):-1:0) #counter that keeps looping
    s = start(ct)
    obs_name, f = processing_func(logsys, log_name)
    add_observer(logsys.observer, obs_name, 
        x->begin
            i,s = next(ct, s)
            if i == 0
                str = join(["$name=$val" for (name,val) in 
                    zip(logsys.db.var_names[log_name],f(x))], ",")
                println(io, "$(log_name): [$str]")
            end
        end)
end
"""
Send a log to IO with custom text generated by user get_str
"""
function send_to!(io::IO, logsys::LogSystem, log_name::AbstractString, get_str::Function;
    interval::Int64=1) 
    ct = cycle((interval-1):-1:0) #counter that keeps looping
    s = start(ct)
    obs_name, f = processing_func(logsys, log_name)
    add_observer(logsys.observer, obs_name, 
        x->begin
            i,s = next(ct, s) 
            i == 0 && println(io, get_str(f(x)))
        end)
end
"""
Send log directly to a Logger
"""
function send_to!{S<:AbstractString}(logger::TaggedDFLogger, logsys::LogSystem, log_names::Vector{S})
    for log_name in log_names
        send_to!(logger, logsys, log_name)
    end
end
function send_to!(logger::TaggedDFLogger, logsys::LogSystem, log_name::AbstractString; 
    interval::Int64=1)
    ct = cycle((interval-1):-1:0) #counter that keeps looping
    s = start(ct)
    obs_name, f = processing_func(logsys, log_name)
    add_folder!(logger, log_name, logsys.db.var_types[log_name], logsys.db.var_names[log_name])
    add_observer(logsys.observer, obs_name, 
        x->begin
            i,s = next(ct, s) 
            i == 0 && push!(logger, log_name, f(x))
        end)
end
#""
#Send log to user-defined function
#"""
#function send_to!(logsys::LogSystem, log_name::AbstractString, user_func::Function) 
    #obs_name, f = processing_func(logsys, log_name)
    #add_observer(logsys.observer, obs_name, x->user_func(f(x)))
#end
#"""
#Send log to Logger (add a folder) but allow user to define how to push
#"""
#function send_to!(TaggedDFLogger, logsys::LogSystem, log_name:AbstractString, 
    #user_func::Function)
    #obs_name, f = processing_func(logsys, log_name)
    #add_folder!(logger, log_name, logsys.db.var_types[log_name], logsys.db.var_names[log_name])
    #add_observer(logsys.observer, obs_name, x->user_func(f(x))))
#end

end #module
