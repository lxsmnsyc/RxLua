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
local M = require "RxLua.src.observer.completable.callback.M"

local isDisposable = require "RxLua.src.disposable.interface.is"
local isDisposed = require "RxLua.src.disposable.interface.isDisposed"
local dispose = require "RxLua.src.disposable.interface.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

local Action = require "RxLua.src.functions.action.new"
local isAction = require "RxLua.src.functions.action.is"
local run = require "RxLua.src.functions.action.run"

local Consumer = require "RxLua.src.functions.consumer.new"
local isConsumer = require "RxLua.src.functions.consumer.is"
local emptyConsumer = require "RxLua.src.functions.consumer.empty"
local accept = require "RxLua.src.functions.consumer.accept"

return function (_, onComplete, onError)
    local context = debug.getinfo(1).name

    local isFunction = type(onComplete) == "function"
    badArgument(isAction(onComplete) or isFunction, 1, context, "Action or function")

    local this = {
        _disposable = nil,
        _className = "CallbackCompletableObserver",
    }

    if(isFunction) then 
        onComplete = Action(nil, onComplete)
    end 

    if(type(onError) == "function") then 
        onError = Consumer(nil, onError)
    elseif(not (onError == nil or isConsumer(onError))) then
        badArgument(false, 2, context, "a Consumer, a function or nil")
    end

    this.onSubscribe = function (d)
        local disposable = this._disposable
        if(disposable) then 
			if(isDisposed(disposable)) then 
				dispose(d)
			else
				error("Protocol Violation: Disposable already set.")
			end
        else
            this._disposable = d
        end 
    end 

    this.onComplete = function ()
        local status, result = pcall(function ()
            run(onComplete)
        end)

        if(not status) then 
            error(result)
        end 
        dispose(this._disposable)
    end 

    this.onError = function (t)
		local status, result = pcall(function ()
			accept(onError, t)
		end)
		

		if(not status) then 
			error(result)
		end 
        dispose(this._disposable)
    end 

    return setmetatable(this, M)
end