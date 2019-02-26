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

local MaybeSource = require "RxLua.source.maybe"

local MaybeObserver = require "RxLua.observer.maybe"
local SingleObserver = require "RxLua.observer.single"
local Disposable = require "RxLua.disposable"

local dispose = require "RxLua.disposable.helper.dispose"
local isDisposed = require "RxLua.disposable.helper.isDisposed"
local replace = require "RxLua.disposable.helper.replace"
local setOnce = require "RxLua.disposable.helper.setOnce"

local ProtocolViolation = require "RxLua.utils.protocolViolation"

local FlatMapMaybeObserver = class("FlatMapMaybeObserver", MaybeObserver){
    new = function (self, parent, downstream)
        self._parent = parent 
        self._downstream = downstream
    end,
    onSubscribe = function (self, d)
        replace(self._parent, d)
    end,
    onSuccess = function (self, x)
        self._downstream:onSuccess(x)
    end,
    onError = function (self, t)
        self._downstream:onError(t)
    end,
    onComplete = function (self)
        self._downstream:onComplete()
    end,
}

local FlatMapMaybeSingleObserver = class("FlatMapMaybeSingleObserver", Disposable, SingleObserver){
    new = function (self, actual, mapper)
        self._downstream = actual 
        self._mapper = mapper 
    end,

    dispose = function (self)
        dispose(self)
    end,

    isDisposed = function (self)
        return isDisposed(self)
    end,

    onSubscribe = function (self, d)
        if(setOnce(self, d)) then 
            self._downstream:onSubscribe(self)
        end
    end,

    onSuccess = function (self, x)
        local try, result = pcall(function ()
            local cs = self._mapper:test(x)
            if(cs == nil) then 
                ProtocolViolation("FlatMapCompletable mapper returned a null MaybeSource")
                return
            elseif(not MaybeSource.instanceof(cs, MaybeSource)) then 
                ProtocolViolation("FlatMapCompletable mapper returned a non-MaybeSource")
                return
            end
            return cs
        end)

        if(try) then 
            if(not isDisposed(self)) then 
                result:subscribe(FlatMapMaybeObserver(self, self._downstream))
            end
        else
            self._downstream:onError(result)
        end
    end,
    onError = function (self, t)
        self._downstream:onError(t)
    end,
}

local Single 
local SingleFlatMapMaybe

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleFlatMapMaybe = class("SingleFlatMapMaybe", Single){
            new = function (self, source, actual)
                self._source = source 
                self._actual = actual
            end, 
            subscribeActual = function (self, observer)
                self._source:subscribe(FlatMapMaybeSingleObserver(observer, self._actual))
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
    return SingleFlatMapMaybe(self, fn)
end