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

local Disposable = require "RxLua.disposable"
local Observer = require "RxLua.observer"

local Action = require "RxLua.functions.action"
local Consumer = require "RxLua.functions.consumer"
local Predicate = require "RxLua.functions.predicate"

local BadArgument = require "RxLua.utils.badArgument"
local ProtocolViolation = require "RxLua.utils.protocolViolation"
local CompositeException = require "RxLua.utils.compositeException"

local DISPOSED = require "RxLua.disposable.helper.disposed"

local validate = require "RxLua.disposable.helper.validate"

return class ("DisposableLambdaObserver", Disposable, Observer){
    new = function (self, actual, onSubscribe, onDispose)
        BadArgument(Observer.instanceof(actual, Observer), 1, "Observer")
        BadArgument(Consumer.instanceof(onSubscribe, Consumer), 2, "Consumer")
        BadArgument(Action.instanceof(onDispose, Action), 2, "Action")

        self._downstream = actual 
        self._onSubscribe = onSubscribe
        self._onDispose = onDispose
    end,

    onSubscribe = function (self, disposable) 
        local try, catch = pcall(function ()
            self._onSubscribe:accept(disposable)
        end)

        if(not catch) then 
            disposable:dispose()
            self._upstream = DISPOSED
            EMPTY.error(self._downstream, catch)
            return
        end 

        if(validate(self._upstream, disposable)) then 
            self._upstream = disposable
            self._downstream:onSubscribe(disposable)
        end 
    end,

    onNext = function (self, x)
        self._downstream:onNext(x)
    end, 

    onError = function (self, t)
        if(self._upstream ~= DISPOSED) then 
            self._upstream = DISPOSED
            self._downstream:onError(t)
        else 
            error(t)
        end
    end,

    onComplete = function (self) 
        if(self._upstream ~= DISPOSED) then 
            self._upstream = DISPOSED
            self._downstream:onComplete(t)
        end
    end,

    isDisposed = function(self)
        return self._upstream:isDisposed()
    end,

    dispose = function(self)
        local d = self._upstream 

        if(d ~= DISPOSED) then 
            self._upstream = DISPOSED
            local try, catch = pcall(function ()
                self.__onDispose:run()
            end)

            if(try) then 
                d:dispose()
            else 
                error(catch)
            end 
        end 
    end 
}