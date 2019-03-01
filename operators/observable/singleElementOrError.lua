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
local new = require "RxLua.single.new"

local dispose = require "RxLua.disposable.dispose"

local function subscribeActual(self, observer)
    local last
    local upstream 
    return self._source:subscribe{
        onSubscribe = function (d)
            upstream = d 
        end,
        onNext = function (x)
            if(last ~= nil) then 
                pcall(observer.onError, "Observable.singleElement: Observable emitted more than one item.")
                dispose(upstream)
            else 
                last = x
            end 
        end,
        onError = function (x)
            pcall(observer.onError, x)
        end,
        onComplete = function ()
            if(last == nil) then 
                pcall(observer.onError, self._default)
            else 
                pcall(observer.onSuccess, last)
            end
        end 
    }
end

local Assert = require "RxLua.utils.assert"
return function (self, default)
    if(Assert(default ~= nil, "bad argument #2 to 'Observable.singleElementOrDefault' (expected a non-nil value)")) then 
        local single = new()
        single._source = self 
        single._default = default
        single.subscribe = subscribeActual
        return single 
    end
end