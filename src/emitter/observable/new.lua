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

local M = require "RxLua.src.emitter.observable.M"

local Disposable = require "RxLua.src.disposable.new"
local isDisposable = require "RxLua.src.disposable.is"
local dispose = require "RxLua.src.disposable.dispose"

return function (_, receiver)
    assert(type(receiver) == "table", "TypeError: receiver is not a table. (received: "..type("receiver")..")")
    --[[
        Tells the observer that it can receive signals
    ]]
    local this = {
        _active = true,
        _className = "ObservableEmitter"
    }

    local onNext = receiver.onNext 
    local onError = receiver.onError
    local onComplete = receiver.onComplete
    
    local recognizeNext = type(onNext) == "function"
    local recognizeError = type(onError) == "function"
    local recognizeComplete = type(onComplete) == "function"
    
    local function isDisposed()
        local disposable = this._disposable
        return disposable and isDisposable(disposable) and disposable.isDisposed
    end 

    local function internalDispose()
        local disposable = this._disposable
        if(disposable and isDisposable(disposable)) then 
            dispose(disposable)
        end 
    end 

    local function isActive()
        return this._active or not isDisposed()
    end 

    local function nextHandler(x)
        if(isActive() and recognizeNext) then 
            onNext(x)
        end 
    end 

    local function errorHandler(err)
        if(isActive()) then 
            this._active = false
            internalDispose()
            if(recognizeError) then 
                onError(err)
            end
        end 
    end 

    local function completeHandler()
        if(isActive()) then 
            this._active = false
            internalDispose()
            if(recognizeComplete) then 
                onComplete()
            end
        end 
    end 

    this.next = nextHandler
    this.error = errorHandler
    this.complete = completeHandler

    return setmetatable(this, M)
end