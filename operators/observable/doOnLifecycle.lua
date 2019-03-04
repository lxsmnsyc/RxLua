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
    local onDispose = self._onDispose
    local onSubscribe = self._onSubscribe
    local disposable = self._source:subscribe{
        onSubscribe = function (d)
            pcall(onSubscribe, d)
            pcall(observer.onSubscribe, d)
        end,
        onNext = observer.onNext,
        onError = observer.onError,
        onComplete = observer.onComplete
    }
    local dispose = disposable.dispose

    disposable.dispose = function (self)
        pcall(onDispose)
        dispose(self)
    end

    return disposable
end

return function (self, onSubscribe, onDispose)
    local observable = new()

    observable._source = self 
    observable._onSubscribe = onSubscribe
    observable._onDispose = onDispose
    observable.subscribe = subscribeActual

    return observable
end