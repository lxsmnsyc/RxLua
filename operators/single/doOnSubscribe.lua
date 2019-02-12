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

local Consumer = require "RxLua.functions.consumer"

local EmptyDisposable = require "RxLua.disposable.empty"

local DoSubSingleObserver = class("DoSubSingleObserver", SingleObserver){
    new = function (self, downstream, actual)
        self._downstream = downstream
        self._actual = actual
        self._done = false
    end, 

    onSuccess = function (self, x)
        if(self._done) then 
            return 
        end
        self._downstream:onSuccess(x)
    end,
    onError = function (self, t)
        if(self._done) then 
            return 
        end
        self._downstream:onError(t)
    end,

    onSubscribe = function (self, d)
        local try, catch = pcall(function ()
            self._actual:accept(d)
        end)

        if(try) then 
            self._downstream:onSubscribe(d)
        else
            self._done = true 
            d:dispose()
            EmptyDisposable.error(self._downstream, catch)
        end
    end
}

local Single 
local SingleDoOnSubscribe



local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleDoOnSubscribe = class("SingleDoOnSubscribe", Single){
            new = function (self, source, actual)
                self._source = source 
                self._actual = actual
            end, 
            subscribeActual = function (self, observer)
                self._source:subscribe(DoSubSingleObserver(observer, self._actual))
            end, 
        }
    end 
end

local BadArgument = require "RxLua.utils.badArgument"

return function (source, onSubscribe)
    if((not Consumer.instanceof(onSubscribe, Consumer)) and type(onSubscribe) == "function") then 
        onSubscribe = Consumer(onSubscribe)
    else 
        BadArgument(false, 1, "Consumer or function")
    end
    asyncLoad()
    return SingleDoOnSubscribe(source, onSubscribe)
end