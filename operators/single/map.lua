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

local Predicate = require "RxLua.functions.predicate"

local SingleObserver = require "RxLua.observer.single"

local MapSingleObserver = class("MapSingleObserver", SingleObserver){
    new = function (self, downstream, mapper)
        self._downstream = downstream
        self._mapper = mapper
    end,

    onSubscribe = function (self, d)
        self._downstream:onSubscribe(d)
    end,

    onSuccess = function (self, x)
        local try, catch = pcall(function ()
            return self._mapper:test(x)
        end)

        if(try) then 
            self._downstream:onSuccess(catch)
        else 
            self._downstream:onError(catch)
        end
    end,

    onError = function (self, t)
        self._downstream:onError(catch)
    end
}

local Single 
local SingleMap

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleMap = class("SingleMap", Single){
            new = function (self, source, mapper)
                self._source = source 
                self._mapper = mapper
            end, 
            subscribeActual = function (self, observer)
                self._source:subscribe(MapSingleObserver(observer, self._mapper))
            end, 
        }
    end 
end

local BadArgument = require "RxLua.utils.badArgument"

return function (self, fn)
    if((not Predicate.instanceof(fn, Predicate)) and type(fn) == "function") then 
        fn = Predicate(fn)
    else 
        BadArgument(false, 1, "Predicate or function")
    end
    asyncLoad()
    return SingleMap(self, fn)
end