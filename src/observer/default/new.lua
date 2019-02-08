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

local M = require "RxLua.src.observer.disposable.M"

local badArgument = require "RxLua.src.asserts.badArgument"


local isAction = require "RxLua.src.functions.action.is"
local run = require "RxLua.src.functions.action.run"

local isConsumer = require "RxLua.src.functions.consumer.is"
local acceptC = require "RxLua.src.functions.consumer.accept"

local isBiConsumer = require "RxLua.src.functions.biconsumer.is"
local acceptBC = require "RxLua.src.functions.biconsumer.accept"

return function (_, receiver)
    badArgument(type(receiver) == "table", 1, debug.getinfo(1).name, "table", type(receiver))

    local onStart = receiver.onStart
    local onNext = receiver.onNext
    local onError = receiver.onError 
    local onComplete = receiver.onComplete

    local startAction = isAction(onStart)
    local nextConsumer = isConsumer(onNext)
    local nextBiConsumer = isBiConsumer(onNext)
    local errorConsumer = isConsumer(onError)
    local completeAction = isAction(onComplete)

    local startFn = type(onStart) == "function"
    local nextFn = type(onNext) == "function"
    local errorFn = type(onError) == "function"
    local completeFn = type(onComplete) == "function"

    local upstream

    local function cancel()
        dispose(upstream)
    end 

    return setmetatable({
        onSubscribe = function (d)
            if(upstream) then 
                error('Protocol Violation: Multiple subscriptions on observer')
            elseif(isDisposable(d)) then
                upstream = d
                if(recognizeStart) then
                    onStart()
                end
            end 
        end, 

        onNext = receiver.onNext,
        onError = receiver.onError,
        onComplete = receiver.onComplete,

        _className = "DefaultObserver"
    }, M)
end