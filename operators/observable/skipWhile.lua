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

local function subscribeActual(self, observer)
    local source = self._source 
    local test = self._test

    local upstream

    local flag 
    
    local onNext = observer.onNext 
    return source:subscribe{
        onSubscribe = function (d)
            upstream = d
        end,
        onNext = function (x)
            if(not flag) then 
                local try, catch = pcall(test, x)
                if(try) then 
                    flag = not catch
                else 
                    dispose(upstream)
                    pcall(observer.onError, catch)
                end
            end 
            if(flag) then 
                pcall(onNext, x)
            end
        end,
        onError = function (x)
            pcall(observer.onError, catch)
        end,
        onComplete = function ()
            pcall(observer.onComplete)
        end
    }
end

local Assert = require "RxLua.utils.assert"
return function (self, predicate)
    if(Assert(type(predicate) == "function", "bad argument #2 to 'Observable.skipWhile' (function expected, got "..type(predicate))) then 
        local observable = new()
        observable.subscribe = subscribeActual
        observable._source = self
        observable._test = predicate 

        return observable
    end
end