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
]] 
local class = require "RxLua.utils.meta.class"

local SingleObserver = require "RxLua.observer.single"

local BiConsumer = require "RxLua.functions.biconsumer"

local HostError = require "RxLua.utils.hostError"

local DoOnEventSingleObserver = class("DoOnEventSingleObserver", SingleObserver){
    new = function (self, downstream, actual)
        self._downstream = downstream
        self._actual = actual
    end, 

    onSuccess = function (self, x)
        local try, catch = pcall(function()
            self._actual:accept(x, nil)
        end)

        if(not try) then 
            self._downstream:onError(catch)
            return
        end
        self._downstream:onSuccess(x)
    end,

    onError = function (self, t)
        local try, catch = pcall(function()
            self._actual:accept(nil, t)
        end)

        if(not try) then 
            t = t.."\n"..catch
        end
        self._downstream:onError(t)
    end,

    onSubscribe = function (self, d)
        self._downstream:onSubscribe(d)
    end
}

local Single 
local SingleDoOnEvent


local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleDoOnEvent = class("SingleDoOnEvent", Single){
            new = function (self, source, actual)
                self._source = source 
                self._actual = actual
            end, 
            subscribeActual = function (self, observer)
                self._source:subscribe(DoOnEventSingleObserver(observer, self._actual))
            end, 
        }
    end 
end

local BadArgument = require "RxLua.utils.badArgument"

return function (source, doOnEvent)
    if((not BiConsumer.instanceof(doOnEvent, BiConsumer)) and type(doOnEvent) == "function") then 
        doOnEvent = BiConsumer(doOnEvent)
    else 
        BadArgument(false, 1, "BiConsumer or function")
    end
    asyncLoad()
    return SingleDoOnEvent(source, doOnEvent)
end