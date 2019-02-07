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

local isDisposable = require "RxLua.src.disposable.is"
local isDisposed = require "RxLua.src.disposable.isDisposed"
local dispose = require "RxLua.src.disposable.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

return function (_, onComplete, onError)
    badArgument(type(onComplete) == "function", 1, debug.getinfo(1).name, "function")

    local this = {
        _disposable = nil,
        _className = "DisposableCompletableObserver",
    }

    local recognizeError = type(onError) == "function"

    this.onComplete = function ()
        dispose(this._disposable)
    end 

    this.onError = function (err)
        local status, result = function ()

        end 
        error(err)
        dispose(this._disposable)
    end 


    this.onSubscribe = function (d)
        if(this._disposable) then 
            error("Protocol Violation: Disposable already set.")
        else 
            this._disposable = d
        end 
    end 

    return setmetatable(this, M)
end