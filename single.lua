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
]] 
local class = require "RxLua.utils.meta.class"

local SingleSource = require "RxLua.source.single"

local path = "RxLua.operators.single"

local function loadOperator(name)
    return require(path.."."..name)
end 
return class ("Single", SingleSource){
    subscribeActual = function (self, observer) end,
    
    create = loadOperator("create"),
    subscribe = loadOperator("subscribe"),

    amb = loadOperator("amb"),

    cache = loadOperator("cache"),
    contains = loadOperator("contains"),

    defer = loadOperator("defer"),
    -- detach = loadOperator("detach"),
    doAfterSuccess = loadOperator("doAfterSuccess"),
    doAfterTerminate = loadOperator("doAfterTerminate"),
    doFinally = loadOperator("doFinally"),
    doOnDispose = loadOperator("doOnDispose"),
    doOnError = loadOperator("doOnError"),
    doOnEvent = loadOperator("doOnEvent"),
    doOnSubscribe = loadOperator("doOnSubscribe"),
    doOnSuccess = loadOperator("doOnSuccess"),
    doOnTerminate = loadOperator("doOnTerminate"),

    equals = loadOperator("equals"),
    error = loadOperator("error"),

    flatMap = loadOperator("flatmap"),
    flatMapCompletable = loadOperator("flatMapCompletable"),
    flatMapMaybe = loadOperator("flatMapMaybe"),
    fromCallable = loadOperator("fromCallable"),
    fromUnsafeSource = loadOperator("fromUnsafeSource"),

    hide = loadOperator("hide"),

    just = loadOperator("just"),

    map = loadOperator("map"),

    never = loadOperator("never")
}