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
--]] 
local new = require "RxLua.maybe.new"

local Emitter = require "RxLua.emitter.maybe"

local dispose = require "RxLua.disposable.dispose"
local isDisposed = require "RxLua.disposable.isDisposed"

local HostError = require "RxLua.utils.hostError"

local function subscribeActual(self, observer)
    local emitter = Emitter(observer.onSuccess, observer.onError, observer.onComplete)
    local try, catch = pcall(observer.onSubscribe, emitter)
    
    try, catch = pcall(self._createSubscriber, emitter)

    if(try) then 
        return emitter
    else 
        emitter:onError(catch)
    end
end


return function (subscriber)
    if(type(subscriber) == "function") then 
        local maybe = new()
    
        maybe._createSubscriber = subscriber
        maybe.subscribe = subscribeActual
    
        return maybe
    else 
        HostError("bad argument #1 to 'Maybe.create' (function expected, got"..type(subscriber)..")")
    end
end