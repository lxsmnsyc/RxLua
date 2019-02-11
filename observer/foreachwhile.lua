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
local CompositeException = require "RxLua.utils.compositeException"

local setOnce = require "RxLua.disposable.helper.setOnce"
local dispose = require "RxLua.disposable.helper.dispose"
local isDisposed = require "RxLua.disposable.helper.isDisposed"
local defaultSet = require "RxLua.disposable.helper.defaultSet"

return class ("ForEachWhileObserver", Disposable, Observer){
    new = function (self, onNext, onError, onComplete)
        BadArgument(Predicate.instanceof(onNext, Predicate), 1, "Predicate")
        BadArgument(Consumer.instanceof(onError, Consumer), 2, "Consumer")
        BadArgument(Action.instanceof(onComplete, Action), 3, "Action")

        self._onNext = onNext 
        self._onError = onError 
        self._onComplete = onComplete
        self._done = false 
    end,

    onSubscribe = function (self, disposable) 
        setOnce(self, disposable)
    end,

    onNext = function (self, x)
        if(self._done) then 
            return 
        end 

        local try, catch = pcall(function ()
            return self._onNext:test(x)
        end)

        if(try) then 
            if(not catch) then 
                dispose(self)
                self:onComplete()
            end 
        else 
            dispose(self)
            self:onError(catch)
        end 
    end, 

    onError = function (self, t) 
        if(self._done) then 
            error(t)
            return
        end 
        self._done = true 
        local try, catch = pcall(function ()
            self._onError:accept(t)
        end)

        if(not try) then 
            CompositeException(t, catch)
        end 
    end,

    onComplete = function (self) 
        if(self._done) then 
            error(t)
            return
        end 
        self._done = true 
        local try, catch = pcall(function ()
            self._onComplete:run()
        end)

        if(not try) then 
            error(catch)
        end 
    end,

    isDisposed = function(self)
        return isDisposed(self)
    end,

    dispose = function(self)
        dispose(self)
    end 
}