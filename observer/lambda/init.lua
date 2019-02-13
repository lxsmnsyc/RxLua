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
local get = require "RxLua.reference.get"

local DISPOSED = require "RxLua.disposable.helper.disposed"


local ProduceAction = require "RxLua.functions.helper.produceAction"
local ProduceConsumer = require "RxLua.functions.helper.produceConsumer"

local HostError = require "RxLua.utils.hostError"

local function errorHandler(self, t)
    if(not isDisposed(self)) then 
        dispose(self)
        local try, catch = pcall(function ()
            self._onError:accept(t)
        end)

        if(not try) then 
            CompositeException(t, catch)
        end 
    else 
        HostError(t)
    end 
end

return class ("LambdaObserver", Disposable, Observer){
    new = function (self, onNext, onError, onComplete, onSubscribe)
        onNext = ProduceConsumer(onNext)
        onError = ProduceConsumer(onError)
        onComplete = ProduceAction(onComplete)
        onSubscribe = ProduceConsumer(onSubscribe)

        BadArgument(onNext, 1, "Consumer, function or nil")
        BadArgument(onError, 2, "Consumer, function or nil")
        BadArgument(onComplete, 3, "Action, function or nil")
        BadArgument(onSubscribe, 4, "Consumer, function or nil")

        self._onNext = onNext
        self._onError = onError
        self._onComplete = onComplete
        self._onSubscribe = onSubscribe 
    end,

    onSubscribe = function (self, disposable) 
        if(setOnce(self, disposable)) then 
            local try, catch = pcall(function ()
                self._onSubscribe:accept(disposable)
            end)
    
            if(not try) then 
                disposable:dispose()
                errorHandler(self, catch)
            end 
        end
    end,

    onNext = function (self, x)
        if(not isDisposed(self)) then 
            local try, catch = pcall(function ()
                self._onNext:accept(x)
            end)
    
            if(not try) then 
                dispose(self)
                errorHandler(self, catch)
            end 
        end 
    end, 

    onError = errorHandler,

    onComplete = function (self) 
        if(not isDisposed(self)) then
            dispose(self)

            local try, catch = pcall(function ()
                self._onComplete:run()
            end)

            if(not try) then 
                HostError(catch)
            end
        end 
    end,

    isDisposed = function(self)
        return isDisposed(self)
    end,

    dispose = function(self)
        dispose(self)
    end 
}