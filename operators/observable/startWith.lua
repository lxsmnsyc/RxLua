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

local dispose = require "RxLua.disposable.dispose"
local isDisposed = require "RxLua.disposable.isDisposed"

local function subscribeActual(self, observer)
    local source = self._source 
    local value = self._value 

    local disposed
    local upstream 

    local function disposeAll()
        disposed = true 
        upstream:dispose()
    end 

    local function isDisposedAll()
        return disposed or upstream:isDisposed()
    end

    local disposable = {
        dispose = disposeAll,
        isDisposed = isDisposedAll 
    }

    pcall(observer.onSubscribe, disposable)

    local onNext = observer.onNext 

    local function coreSubscribe()
        if(not disposed) then 
            source:subscribe{
                onSubscribe = function (d)
                    upstream = d 
                end,
                onNext = onNext,
                onError = observer.onError,
                onComplete = observer.onComplete
            }
        end
    end

    if(is(value)) then 
        value:subscribe{
            onSubscribe = function (d)
                upstream = d
            end,
            onNext = function (x)
                pcall(observer.onNext, x)
            end,
            onError = observer.onError,
            onComplete = function ()
                coreSubscribe()
            end,
        }
    elseif(type(value) == "table") then 
        for k, v in pairs(value) do 
            pcall(observer.onNext, v)
            if(disposed) then 
                return disposable
            end
        end 
        coreSubscribe()
    else 
        pcall(observer.onNext, value)
        coreSubscribe()
    end 

    return disposable
end 

local Assert = require "RxLua.utils.assert"
return function (self, value)
    if(Assert(value ~= nil, "bad argument #2 to 'Observable.startWith' (non-nil expected)")) then 
        local observable = new()
        observable._source = self 
        observable._value = value
        observable.subscribe = subscribeActual
        return observable 
    end 
end