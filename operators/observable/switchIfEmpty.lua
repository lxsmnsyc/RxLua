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
    local backup = self._backup

    local disposed 
    local upstream 

    local disposable = {
        dispose = function ()
            disposed = true 
            upstream:dispose()
        end,
        isDisposed = function ()
            return disposed or upstream:isDisposed()
        end,
    }

    local onNext = observer.onNext 

    pcall(observer.onSubscribe, disposable)

    local empty = true 
    local function startBackup()
        backup:subscribe{
            onSubscribe = function (d)
                upstream = d 
            end,
            onNext = onNext,
            onError = observer.onError,
            onComplete = observer.onComplete
        }
    end

    source:subscribe{
        onSubscribe = function (d)
            upstream = d 
        end,
        onNext = function (x)
            empty = false 
            pcall(onNext, x)        
        end,
        onError = observer.onError, 
        onComplete = function ()
            if(empty) then 
                startBackup()
            else 
                pcall(observer.onComplete)
            end 
        end,
    }
    return disposable
end

local Assert = require "RxLua.utils.assert"
return function (self, backup)
    if(Assert(is(backup), "bad argument #2 to 'Observable.switchIfEmpty' (Observable expected)")) then 
        local observable = new()
        observable._source = self
        observable._backup = backup
        observable.subscribe = subscribeActual
        return observable
    end 
end