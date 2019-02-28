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

local HostError = require "RxLua.utils.hostError"

local function subscribeActual(self, observer)
    local onSuccess = observer.onSuccess
    local onError = observer.onError
    
    observer.onSuccess = function (x)
        local try, catch = pcall(self._comparer, x, self._value)

        if(try) then 
            pcall(onSuccess, catch)
        else 
            pcall(onError, catch)
        end
    end

    return self._source:subscribe(observer)
end

local function equality(a, b) return a == b end

return function (self, value, fn)
    fn = fn == nil and equality or fn
    if(type(fn) == "function") then 
        local maybe = new()

        maybe._source = self
        maybe._comparer = fn or equality
        maybe._value = value
        maybe.subscribe = subscribeActual

        return maybe
    else 
        HostError("bad argument #3 to 'Maybe.contains' (function expected, got"..type(fn)..")")
    end
end