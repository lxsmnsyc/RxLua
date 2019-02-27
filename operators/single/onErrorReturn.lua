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

local CompositeException = require "RxLua.utils.compositeException"
local SingleObserver = require "RxLua.observer.single"

local OnErrorReturnSingleObserver = class ("OnErrorReturnSingleObserver", SingleObserver){
    new = function (self, observer, supplier, value)
        self._observer = observer
        self._supplier = supplier
        self._value = value
    end,

    onError = function (self, e)
        local v

        local observer = self._observer
        if(self._supplier) then 
            local try, catch = pcall(function ()
                return self._supplier:test(e)
            end)
            if(try) then 
                v = catch
            else 
                observer:onError(CompositeException(e, catch))
                return 
            end
        else
            v = self._value
        end

        if(v) then
            observer:onSuccess(v)
        else
            observer:onError("ProtocolViolation: Value supplied is nil (cause: "..v..")")
        end
    end,

    onSubscribe = function (self, d)
        self._observer:onSubscribe(d)
    end,

    onSuccess = function (self, x)
        self._observer:onSuccess(x)
    end
}


local Single 
local SingleOnErrorReturn

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleOnErrorReturn = class("SingleOnErrorReturn", Single){
            new = function (self, source, supplier, value)
                self._source = source 
                self._supplier = supplier
                self._value = value
            end, 
            subscribeActual = function (self, observer)
                self._source:subscribe(OnErrorReturnSingleObserver(observer, self._supplier, self._value))
            end, 
        }
    end 
end

local Predicate = require "RxLua.functions.predicate"
local BadArgument = require "RxLua.utils.badArgument"

return function (self, fn)
    asyncLoad()
    if((not Predicate.instanceof(fn, Predicate)) and type(fn) == "function") then 
        fn = Predicate(fn)
    else 
        return SingleOnErrorReturn(self, nil, fn)
    end
    return SingleOnErrorReturn(self, fn)
end