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

local class = require "Rx.utils.meta.class"

local Disposable = require "Rx.disposable"
local MaybeObserver = require "Rx.observer.maybe"

local Action = require "Rx.functions.action"
local Consumer = require "Rx.functions.consumer"

local BadArgument = require "Rx.utils.badArgument"
local CompositeException = require "Rx.utils.compositeException"


local setOnce = require "Rx.disposable.helper.setOnce"
local dispose = require "Rx.disposable.helper.dispose"
local isDisposed = require "Rx.disposable.helper.isDisposed"
local get = require "Rx.disposable.helper.get"

local DISPOSED = require "Rx.disposable.helper.disposed"


local ProduceAction = require "Rx.functions.helper.produceAction"
local ProduceConsumer = require "Rx.functions.helper.produceConsumer"

return class ("CallbackMaybeObserver", Disposable, MaybeObserver){
    new = function (self, onSuccess, onError, onComplete, onSubscribe)
        onSuccess = ProduceConsumer(onSuccess)
        onError = ProduceConsumer(onError)
        onComplete = ProduceAction(onComplete)

        BadArgument(onSuccess, 1, "Consumer, function or nil")
        BadArgument(onError, 2, "Consumer, function or nil")
        BadArgument(onComplete, 3, "Action, function or nil")

        self._onSuccess = onSuccess
        self._onError = onError
        self._onComplete = onComplete
    end,

    onSubscribe = function (self, disposable) 
        if(setOnce(self, disposable)) then 
            local try, catch = pcall(function ()
                self._onSubscribe:accept(disposable)
            end)
    
            if(not try) then 
                disposable:dispose()
                self:onError(catch)
            end 
        end
    end,

    onSuccess = function (self, x)
        if(not isDisposed(self)) then 
            dispose(self)
            self._onSuccess:accept(x)
        end
    end, 

    onError = function (self, t)
        if(not isDisposed(self)) then 
            dispose(self)
            local try, catch = pcall(function ()
                self._onError:accept(t)
            end)
    
            if(not try) then 
                CompositeException(t, catch)
            end 
        end 
    end,

    onComplete = function (self) 
        if(not dispose(self)) then
            dispose(self)
            self._onComplete:run()
        end 
    end,

    isDisposed = function(self)
        return isDisposed(self)
    end,

    dispose = function(self)
        dispose(self)
    end 
}