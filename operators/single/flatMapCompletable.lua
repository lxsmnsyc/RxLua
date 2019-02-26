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

local CompletableSource = require "RxLua.source.completable"

local SingleObserver = require "RxLua.observer.single"
local CompletableObserver = require "RxLua.observer.completable"
local Disposable = require "RxLua.disposable"

local dispose = require "RxLua.disposable.helper.dispose"
local isDisposed = require "RxLua.disposable.helper.isDisposed"
local replace = require "RxLua.disposable.helper.replace"
local setOnce = require "RxLua.disposable.helper.setOnce"

local ProtocolViolation = require "RxLua.utils.protocolViolation"

local FlatMapCompletableObserver = class("FlatMapCompletableObserver", SingleObserver, CompletableObserver, Disposable){
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
        replace(self, d)
    end,

    onSuccess = function (self, x)
        local try, result = pcall(function ()
            local cs = self._mapper:test(x)
            
            if(cs == nil) then 
                ProtocolViolation("FlatMapCompletable mapper returned a null CompletableSource")
                return
            elseif(not CompletableSource.instanceof(cs, CompletableSource)) then 
                ProtocolViolation("FlatMapCompletable mapper returned a non-CompletableSource")
                return
            end
            return cs
        end)

        if(try) then 
            if(not isDisposed(self)) then 
                result:subscribe(self)
            end
        else
            self._downstream:onError(result)
        end
    end,

    onError = function (self, t)
        self._downstream:onError(t)
    end,

    onComplete = function (self)
        self._downstream:onComplete()
    end
}

local Completable 
local SingleFlatMapCompletable

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Completable = require "RxLua.completable"
        SingleFlatMapCompletable = class("SingleFlatMapCompletable", Completable){
            new = function (self, source, actual)
                self._source = source 
                self._actual = actual
            end, 
            subscribeActual = function (self, observer)
                local parent = FlatMapCompletableObserver(observer, self._actual)
                observer:onSubscribe(parent)
                self._source:subscribe(parent)
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
    return SingleFlatMapCompletable(self, fn)
end