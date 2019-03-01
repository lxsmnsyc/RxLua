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
local isDisposed = require "RxLua.disposable.isDisposed"

local function subscribeActual(self, observer)
    local onSubscribe = observer.onSubscribe
    local onSuccess = observer.onSuccess 
    local onError = observer.onError 

    local done = false
    local upstream 

    local newError = function (t)
        if(done) then 
            HostError(t)
            return 
        end
        done = true 
        pcall(onError, t)
    end

    return self._source:subscribe{
        onSubscribe = function (d)
            if(upstream) then 
                dispose(d)
            else
                upstream = d 
                pcall(onSubscribe, d)
            end
        end,
        onNext = function (x)
            if(done) then 
                return 
            end
            if(not isDisposed(upstream)) then 
                local try, catch = pcall(self._predicate, x)
                if(try) then 
                    if(catch) then
                        done = true
                        pcall(onSuccess, true)
                        dispose(upstream)
                    end
                else 
                    newError(catch)
                end
            end
        end,

        onError = newError,
        onComplete = function ()
            if(not done) then 
                done = true 
                pcall(onSuccess, false)
            end
        end
    }
end 

local Assert = require "RxLua.utils.assert"
return function (self, fn)
    if(Assert(type(fn) == "function", "bad argument #2 to 'Observable.any' (function expected, got"..type(fn)..")")) then 
        local single = new()
    
        single._source = self
        single._predicate = fn
        single.subscribe = subscribeActual
    
        return single
    end
end