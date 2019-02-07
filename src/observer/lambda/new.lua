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

local M = require "RxLua.src.observer.M"

local isDisposable = require "RxLua.src.disposable.is"
local isDisposed = require "RxLua.src.disposable.isDisposed"
local dispose = require "RxLua.src.disposable.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

return function (_, onNext, onError, onComplete, onSubscribe)
    local recognizeNext = type(onNext) == "function"
    local recognizeError = type(onError) == "function"
    local recognizeComplete = type(onComplete) == "function"
    local recognizeSubscribe = type(onSubscribe) == "function"

    local this = {
        _disposable = nil,
        _className = "LambdaObserver"
    }

    local function errorHandler(err)
        local disposable = this._disposable
        if(isDisposed(disposable)) then
            error(err)
        else 
            dispose(disposable)
            if(recognizeError) then 
                local status, result = pcall(function ()
                    onError(err)
                end)

                if(not status) then 
                    error(err + "\n" + result)
                end 
            end
        end 
    end

    this.onSubscribe = function (d)
        if(this._disposable) then 
            error("Protocol Violation: Disposable already set.")
        else 
            this._disposable = d

            if(recognizeSubscribe) then 
                local status, result = pcall(function (d)
                    onSubscribe(d)
                end)

                if(not status) then 
                    dispose(d)
                    errorHandler(result)
                end 
            end 
        end 
    end 

    this.onNext = function (x)
        local disposable = this._disposable
        if(not isDisposed(disposable)) then 
            if(recognizeNext) then 
                local status, result = pcall(function ()
                    onNext(x)
                end)

                if(not status) then 
                    dispose(disposable)
                    errorHandler(result)
                end 
            end
        end 
    end

    this.onComplete = function ()
        local disposable = this._disposable
        if(not isDisposed(disposable)) then 
            dispose(disposable)
            if(recognizeComplete) then 
                local status, result = pcall(function ()
                    onComplete(x)
                end)

                if(not status) then 
                    errorHandler(result)
                end 
            end
        end 
    end 

    return setmetatable(this, M)
end 