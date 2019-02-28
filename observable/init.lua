--[[
    Reactive Extensions for Lua
	
    MIT License
    Copyright (c) 2019 Alexis Munsayac
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]] 
local M = require "RxLua.observable.M"

M.__call = require "RxLua.observable.new"

local function operator(name)
    return require("RxLua.operators.observable."..name)
end 

M.__index = {

    amb = operator("amb"),
    all = operator("all"),
    any = operator("any"),

    blockingFirst = operator("blockingFirst"),
    blockingForEach = operator("blockingForEach"),
    blockingIterable = operator("blockingIterable"),
    blockingLast = operator("blockingLast"),

    contains = operator("contains"),
    count = operator("count"),
    create = operator("create"),

    defer = operator("defer"),
    doAfterNext = operator("doAfterNext"),
    doAfterTerminate = operator("doAfterTerminate"),
    doFinally = operator("doFinally"),
    doOnComplete = operator("doOnComplete"),
    doOnDispose = operator("doOnDispose"),
    doOnEach = operator("doOnEach"),
    doOnError = operator("doOnError"),
    doOnLifecycle = operator("doOnLifecycle"),
    doOnNext = operator("doOnNext"),
    doOnSubscribe = operator("doOnSubscribe"),
    
    empty = operator("empty"),
    error = operator("error"),

    ignoreElements = operator("ignoreElements"),
    isEmpty = operator("isEmpty"),

    just = operator("just"),

    map = operator("map")
}

return setmetatable({}, M)