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
local M = require "RxLua.src.observer.maybe.callback.M"

local isDisposable = require "RxLua.src.disposable.interface.is"
local isDisposed = require "RxLua.src.disposable.interface.isDisposed"
local dispose = require "RxLua.src.disposable.interface.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

local isAction = require "RxLua.src.functions.action.is"
local run = require "RxLua.src.functions.action.run"

local isConsumer = require "RxLua.src.functions.consumer.is"
local accept = require "RxLua.src.functions.consumer.accept"

local produceAction = require "RxLua.src.functions.action.produce"
local produceConsumer = require "RxLua.src.functions.consumer.produce"

local emptyAction = require "RxLua.src.functions.action.empty"
local emptyConsumer = require "RxLua.src.functions.consumer.empty"

return function (_, onSuccess, onError, onComplete)
    local this = {
        _disposable = nil,
        _className = "CallbackMaybeObserver",
    }

    onSuccess = produceConsumer(onSuccess, emptyConsumer)
    onError = produceConsumer(onError, emptyConsumer)
    onComplete = produceAction(onComplete, emptyAction)

    badArgument(onSuccess, 1, context, "either an Consumer, a function or nil")
    badArgument(onError, 2, context, "either an Consumer, a function or nil")
    badArgument(onComplete, 3, context, "either an Action, a function or nil")


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

    this.onSuccess = function (x)
        dispose(this._disposable)
        local status, result = pcall(function ()
            accept(onSuccess, x)
        end)

        if(not status) then 
            error(result)
        end 
    end 

    this.onComplete = function ()
        dispose(this._disposable)
        local status, result = pcall(function ()
            run(onComplete)
        end)

        if(not status) then 
            error(result)
        end 
    end 

	this.onError = function (t)
        dispose(this._disposable)
        local status, result = pcall(function ()
            accept(onError, t)
        end)

        if(not status) then 
            error(result)
        end 
    end 


    return setmetatable(this, M)
end