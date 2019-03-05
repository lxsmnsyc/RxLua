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
local is = require "RxLua.observable.is"

local Error = require "RxLua.disposable.error"

local function subscribeActual(self, observer)
    local try, catch = pcall(self._deferredFunction)

    if(try) then 
        if(catch) then 
            if(is(catch)) then 
                return catch:subscribe(observer)
            end
        else 
            return Error(observer, "The deferred function returned a non-Single value.")
        end
    else 
        return Error(observer, "The deferred function encountered an error: "..catch)
    end
end

local Assert = require "RxLua.utils.assert"
return function (fn)
    if(Assert(type(fn) == "function", "bad argument #1 to 'Observable.defer' (function expected, got"..type(fn)..")")) then 
        local observable = new()
    
        observable._deferredFunction = fn
        observable.subscribe = subscribeActual
    
        return observable
    end
end