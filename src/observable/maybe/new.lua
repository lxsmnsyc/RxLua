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
local M = require "RxLua.src.observable.maybe.M"

local onSubscribe = require "RxLua.src.onSubscribe.maybe.new"
local isOnSubscribe = require "RxLua.src.onSubscribe.maybe.is"

local Emitter = require "RxLua.src.emitter.maybe.new"

local isDisposable = require "RxLua.src.disposable.interface.is"
local isDisposed = require "RxLua.src.disposable.interface.isDisposed"
local dispose = require "RxLua.src.disposable.interface.dispose"

local subscribe = require "RxLua.src.onSubscribe.maybe.subscribe"

local badArgument = require "RxLua.src.asserts.badArgument"

local function subscribeActual(observable, observer)
    local emitter = Emitter(nil, observer)

    local disposable

    emitter.onSuccess = function(x)
        if(disposable and not isDisposed(disposable)) then 
            local status, result = pcall(function ()
                if(x == nil) then 
                    observer.onError("Protocol Violation: onSuccess called with nil: nil values are not allowed.")
                else
                    observer.onSuccess(x)
                end
            end)
            dispose(disposable)
        end
    end 

    emitter.onComplete = function()
        if(disposable and not isDisposed(disposable)) then 
            local status, result = pcall(function ()
                observer.onComplete()
            end)
            dispose(disposable)
        end
    end 

    local function tryError(t)
        if(t == nil) then 
            t = "onError called with nil: nil values are not allowed."
        end

        if(disposable and not isDisposed(disposable)) then 
            local status, result = pcall(function ()
                observer.onError(t)
            end)
            dispose(disposable)

            return true 
        end
        return false
    end

    emitter.onError = function(t)
        if(not tryError(t)) then 
            error(t)
        end 
    end 

    emitter.setDisposable = function(d)
        if(disposable and d ~= disposable) then
            if(isDisposed(disposable)) then 
                dispose(d)
                return 
            else
                dispose(disposable)
            end
        end
        disposable = d
    end 

    emitter.isDisposed = function()
        return disposable and isDisposed(disposable)
    end 

    emitter.dispose = function()
        return disposable and dispose(disposable)
    end 


    local onSubscribe = observer.onSubscribe
    if(onSubscribe) then 
        onSubscribe(emitter)
    end 

    local status, result = pcall(function ()
        subscribe(observable._subscriber, emitter)
    end)

    if(not status) then 
        emitter.error(result)
    end 
end

local function defaultModify(observable, observer) 
    return observer 
end

return function (_, subscriber)
    local isFunction = type(subscriber) == "function"
    badArgument(isFunction or isOnSubscribe(subscriber), 1, debug.getinfo(1).name , "MaybeOnSubscribe or function")

    if(isFunction) then 
        subscriber = OnSubscribe(nil, subscriber)
    end
    return setmetatable({
        _modify = defaultModify,
        _subscribeActual = subscribeActual,
        _subscriber = subscriber,
        _className = "Maybe"
    }, M)
end