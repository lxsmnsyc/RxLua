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
local M = require "RxLua.src.observer.maybe.disposable.M"

local isDisposable = require "RxLua.src.disposable.interface.is"
local isDisposed = require "RxLua.src.disposable.interface.isDisposed"
local dispose = require "RxLua.src.disposable.interface.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

return function (_, receiver)
    badArgument(type(receiver) == "table", 1, debug.getinfo(1).name, "table", type(receiver))

    local onStart = produceAction(receiver.onStart, emptyAction)
    local onSuccess = produceConsumer(receiver.onSuccess, emptyConsumer)
    local onError = produceConsumer(receiver.onError, emptyConsumer)

    assert(onStart, "Protocol Violation: onStart must be either an Action, a function or nil.")
    assert(onNext, "Protocol Violation: onNext must be either a Consumer, a function or nil.")
    assert(onError, "Protocol Violation: onError must be either a Consumer, a function or nil.")

	local this = {
        _disposable = nil,
        _className = "DisposableSingleObserver",
        
        onSuccess = function (x)
            accept(onSuccess, x) 
        end,
        onError = function (t)
            accept(onError, t)
        end,
        onComplete = function ()
            run(onComplete)
        end,
    }
	
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
			
			run(onStart)
        end 
    end 

    return setmetatable(this, M)
end