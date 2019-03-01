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
    local onNext = observer.onNext

    local afterNext = self._afterNext
    
    observer.onNext = function (x)
        pcall(onNext, x)
        pcall(afterNext, x)
    end

    return self._source:subscribe(observer)
end

return function (self, afterNext)
    if(type(afterNext) == "function") then 
        local observable = new()

        observable._source = self 
        observable._afterNext = afterNext
        observable.subscribe = subscribeActual

        return observable
    else 
        HostError("bad argument #2 to 'Observable.doAfterNext' (function expected, got"..type(fn)..")")
    end
end