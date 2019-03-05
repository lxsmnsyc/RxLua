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
local is = require "RxLua.observable.is" 
local new = require "RxLua.observable.new"

local function subscribeActual(self, observer)
    
    local disposed 
    local upstreamA
    local upstreamB 

    local function disposeBoth()
        disposed = true 
        upstreamA:dispose()
        upstreamB:dispose()
    end

    local function isDisposedBoth()
        return disposed or (upstreamA:isDisposed() and upstreamB:isDisposed())
    end 

    local disposable = {
        dispose = disposeBoth,
        isDisposed = isDisposedBoth
    }

    pcall(observer.onSubscribe, disposable)

    local source = self._source 
    local other = self._other

    local emitted = false 

    other:subscribe{
        onSubscribe = function (d)
            if(disposed) then 
                d:dispose()
            else
                upstreamA = d 
            end
        end,

        onNext = function (x)
            emitted = true
        end,

        onError = function (x)
            disposeBoth()
        end,

        onComplete = function ()
            emitted = true 
        end
    }

    local onNext = observer.onNext 

    source:subscribe{
        onSubscribe = function (d)
            if(disposed) then
                d:dispose()
            else
                upstreamB = d 
            end
        end,

        onNext = function (x)
            if(emitted) then 
                pcall(observer.onComplete)
                disposeBoth()
            else
                pcall(observer.onNext, x)
            end
        end,
        
        onError = function (x)
            pcall(observer.onError, x)
            disposeBoth()
        end,

        onComplete = function ()
            pcall(observer.onComplete)
            disposeBoth()
        end
    }

    return disposable
end

local Assert = require "RxLua.utils.assert"
return function (self, other)
    if(Assert(is(other), "bad argument #2 to 'Observable.takeUntil' (Observable expected)")) then 
        local observable = new()

        observable._source = self 
        observable._other = other 
        observable.subscribe = subscribeActual 

        return observable
    end
end