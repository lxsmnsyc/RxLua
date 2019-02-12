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

local ContainsSingleObserver = class("ContainsSingleObserver", SingleObserver){
    new = function (self, observer, value, comparer)
        self._downstream = observer 
        self._comparer = comparer
        self._value = value
    end, 

    onSubscribe = function (self, d)
        self._downstream:onSubscribe(d)
    end,

    onSuccess = function (self, x)
        local try, catch = pcall(function ()
            return self._comparer:test(x, self._value)
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
local SingleContains 


local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleContains = class("SingleContains", Single){
            new = function (self, source, value, comparer)
                self._source = source 
                self._comparer = comparer
                self._value = value
            end, 

            subscribeActual = function (self, observer)
                self._source:subscribe(ContainsSingleObserver(observer, self._value, self._comparer))
            end
        }
    end
end 

local BiPredicate = require "RxLua.functions.bipredicate"
local equalBiPredicate = require "RxLua.functions.helper.equalBiPredicate"
local BadArgument = require "RxLua.utils.badArgument"

return function (source, value, comparer)
    BadArgument(value ~= nil, 1, "non-nil value", "nil")
    if(type(comparer) == "function") then 
        comparer = BiPredicate(comparer)
    elseif((not BiPredicate.instanceof(comparer, BiPredicate)) and comparer == nil) then
        comparer = equalBiPredicate
    else 
        comparer = false 
    end 
    BadArgument(comparer, 2, "BiPredicate, function or nil")

    asyncLoad()
    return SingleContains(source, value, comparer)
end 