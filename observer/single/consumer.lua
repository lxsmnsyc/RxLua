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
local SingleObserver = require "Rx.observer.single"

local Consumer = require "Rx.functions.consumer"

local CompositeException = require "Rx.utils.compositeException"
local BadArgument = require "Rx.utils.badArgument"

local ProduceConsumer = require "Rx.functions.helper.produceConsumer"

return class ("ConsumerSingleObserver", Disposable, SingleObserver){
    new = function (self, onSuccess, onError)
        onSuccess = ProduceConsumer(onSuccess)
        onError = ProduceConsumer(onError)
        BadArgument(onSuccess, 1, "Consumer, function or nil")
        BadArgument(onError, 2, "Consumer, function or nil")
        self._onSuccess = onSuccess
        self._onError = onError
    end,

    onSubscribe = function (self, disposable) 
        setOnce(self, disposable)
    end,
    
    onSuccess = function (self, x)
        defaultSet(self, DISPOSED)
        local try, catch = pcall(function ()
            self._onCallback:accept(x, nil)
        end)

        if(not try) then 
            error(catch)
        end 
    end,
    
    onError = function (self, t)
        defaultSet(self, DISPOSED)
        local try, catch = pcall(function ()
            self._onCallback:accept(nil, t)
        end)

        if(not try) then 
            error(catch)
        end 
    end,

    dispose = function (self)
        dispose(self)
    end,

    isDisposed = function (self)
        return isDisposed(self)
    end
}