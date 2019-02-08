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
local M = require "RxLua.src.observer.single.biconsumer.M"

local isDisposable = require "RxLua.src.disposable.interface.is"
local isDisposed = require "RxLua.src.disposable.interface.isDisposed"
local dispose = require "RxLua.src.disposable.interface.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

local isBiConsumer = require "RxLua.src.functions.biconsumer.is"
local accept = require "RxLua.src.functions.biconsumer.accept"
local produceBiConsumer = require "RxLua.src.functions.biconsumer.produce"
local emptyBiConsumer = require "RxLua.src.functions.biconsumer.empty"

return function (_, onCallback)
    local this = {
        _disposable = nil,
        _className = "BiConsumerSingleObserver",
    }

    onCallback = produceBiConsumer(onCallback)

    local context = debug.getinfo(1).name 

    badArgument(onCallback, 1, context, "either an BiConsumer, a function or nil")


    this.onSubscribe = function (d)
        if(this._disposable) then 
            error("Protocol Violation: Disposable already set.")
        else 
            this._disposable = d
        end 
    end 

    this.onSuccess = function (x)
        dispose(this._disposable)
        local status, result = pcall(function ()
            accept(onCallback, x, nil)
        end)

        if(not status) then 
            error(result)
        end 
    end

    this.onError = function (t)
        dispose(this._disposable)
        local status, result = pcall(function ()
            accept(onCallback, nil, t)
        end)

        if(not status) then 
            error(result)
        end 
    end 


    return setmetatable(this, M)
end