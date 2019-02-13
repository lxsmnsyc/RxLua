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
local CompletableObserver = require "RxLua.observer.completable"

local Action = require "RxLua.functions.action"
local Consumer = require "RxLua.functions.consumer"

local BadArgument = require "RxLua.utils.badArgument"

local setOnce = require "RxLua.disposable.helper.setOnce"
local dispose = require "RxLua.disposable.helper.dispose"
local isDisposed = require "RxLua.disposable.helper.isDisposed"

local ProduceConsumer = require "RxLua.functions.helper.produceConsumer"

local HostError = require "RxLua.utils.hostError"

return class ("CallbackCompletableObserver", Disposable, CompletableObserver){
    new = function (self, onComplete, onError)
        if((not Action.instanceof(onComplete, Action)) and type(onComplete) == "function") then 
            onComplete = Action(onComplete)
        else
            BadArgument(false, 1, "Action or function")
        end 
        
        self._onComplete = onComplete
            
        onError = ProduceConsumer(onError)
        BadArgument(onError, 2, "Consumer, function or nil")
        self._onError = onError
    end,

    onSubscribe = function (self, disposable) 
        setOnce(self, disposable)
    end,
    
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
    
    onError = function (self, t)
        if(not isDisposed(self)) then 
            dispose(self)
            local try, catch = pcall(function ()
                self._onError:accept(t)
            end)
            if(not try) then 
                HostError(catch)
            end
        end
    end,

    dispose = function (self)
        dispose(self)
    end,

    isDisposed = function (self)
        return isDisposed(self)
    end 
}