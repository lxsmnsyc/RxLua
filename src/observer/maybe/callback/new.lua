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

return function (_, onSuccess, onError, onComplete)
    local this = {
        _disposable = nil,
        _className = "CallbackMaybeObserver",
    }

    local recognizeSuccess = type(onSuccess) == "function"
    local recognizeError = type(onError) == "function"
    local recognizeComplete = type(onComplete) == "function"


    this.onSubscribe = function (d)
        if(this._disposable) then 
            error("Protocol Violation: Disposable already set.")
        else 
            this._disposable = d
        end 
    end 

    this.onSuccess = function (x)
        if(recognizeSuccess) then 
            local status, result = pcall(onSuccess, x)

            if(not status) then 
                error(result)
            end 
        end
        dispose(this._disposable)
    end 

    this.onComplete = function ()
        if(recognizeComplete) then 
            local status, result = pcall(onComplete)

            if(not status) then 
                error(result)
            end 
        end
        dispose(this._disposable)
    end 

    this.onError = function (err)
        if(recognizeError) then 
            local status, result = pcall(function ()
                return onError(err)
            end)
    
            if(not status) then 
                error(result)
            end 
        end 
        dispose(this._disposable)
    end 


    return setmetatable(this, M)
end