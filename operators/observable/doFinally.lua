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
local new = require "RxLua.observable.new"
local HostError = require "RxLua.utils.hostError"

local function subscribeActual(self, observer)

    local onFinally = self._onFinally
    
    local disposable = self._source:subscribe{
        onSubscribe = observer.onSubscribe,
        onNext = observer.onNext,
        onError = function (x)
            pcall(observer.onError, x)
            pcall(onFinally)
        end,
        onComplete = function ()
            pcall(observer.onComplete)
            pcall(onFinally)
        end
    }
    local disposable = self._source:subscribe(observer)
    local dispose = disposable.dispose

    disposable.dispose = function (self)
        dispose(self)
        pcall(onFinally)
    end

    return disposable
end

local Assert = require "RxLua.utils.assert"
return function (self, onFinally)
    if(Assert(type(onFinally) == "function", "bad argument #2 to 'Observable.doOnFinally' (function expected, got"..type(fn)..")")) then 
        local observable = new()

        observable._source = self 
        observable._onFinally = onFinally
        observable.subscribe = subscribeActual

        return observable
    end
end