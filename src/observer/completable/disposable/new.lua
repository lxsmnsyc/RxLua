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
local M = require "RxLua.src.observer.completable.disposable.M"

local isDisposable = require "RxLua.src.disposable.interface.is"
local isDisposed = require "RxLua.src.disposable.interface.isDisposed"
local dispose = require "RxLua.src.disposable.interface.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

local isConsumer = require "RxLua.src.functions.consumer.is"
local accept = require "RxLua.src.functions.consumer.accept"

local isAction = require "RxLua.src.functions.action.is"
local run = require "RxLua.src.functions.action.run"

return function (_, receiver)
    badArgument(type(receiver) == "table", 1, debug.getinfo(1).name, "table", type(receiver))

    local onStart = receiver.onStart
    local onError = receiver.onError 
    local onComplete = receiver.onComplete

    local startAction = isAction(onStart)
    local errorConsumer = isConsumer(onError)
    local completeAction = isAction(onComplete)

    local startFn = type(onStart) == "function"
    local errorFn = type(onError) == "function"
    local completeFn = type(onComplete) == "function"

    assert(startAction or startFn, "Protocol Violation: onStart must be either an Action or a function.")
    assert(errorConsumer or errorFn, "Protocol Violation: onError must be either a Consumer or a function.")
    assert(completeAction or completeFn, "Protocol Violation: onComplete must be either an Action or a function.")

    local function errorHandler(t)
        if(errorFn) then 
            onError(t)
        elseif(errorConsumer) then 
            accept(onError, t)
        end
    end 

    local function completeHandler()
        if(completeFn) then 
            onComplete()
        elseif(completeAction) then 
            run(onComplete)
        end 
    end 

    local function startHandler()
        if(startFn) then 
            onStart()
        elseif(startAction) then 
            run(onStart)
        end 
    end 

    local this = {
        _disposable = nil,
        _className = "DisposableCompletableObserver",
        
        onError = errorHandler,
        onComplete = completeHandler
    }

    this.onSubscribe = function (d)
        if(this._disposable) then 
            error("Protocol Violation: Disposable already set.")
        elseif(isDisposable(d)) then
            this._disposable = d

            startHandler()
        end 
    end 

    return setmetatable(this, M)
end