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
local M = require "RxLua.maybe.M"

local HostError = require "RxLua.utils.hostError"

local function subscribeActual(self, observer)
    local try, catch = pcall(self._deferredFunction)

    if(try) then 
        if(catch) then 
            if(getmetatable(catch) == M) then 
                return catch:subscribe(observer)
            end
        else 
            observer.onError("The deferred function returned a non-Single value.")
        end
    else 
        observer.onError("The deferred function encountered an error: "..catch)
    end
end

return function (fn)
    if(type(fn) == "function") then 
        local maybe = new()

        maybe._deferredFunction = fn
        maybe.subscribe = subscribeActual

        return maybe
    else 
        HostError("bad argument #1 to 'Maybe.defer' (function expected, got"..type(fn)..")")
    end
end