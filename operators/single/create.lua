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


local SingleObserver = require "Rx.observer.single"
local SingleOnSubscribe = require "Rx.onSubscribe.single"

local DISPOSED = require "Rx.disposable.helper.disposed"
local getAndSet = require "Rx.disposable.helper.getAndSet"
local set = require "Rx.disposable.helper.set"
local dispose = require "Rx.disposable.helper.dispose"
local isDisposed = require "Rx.disposable.helper.isDisposed"

local BadArgument = require "Rx.utils.badArgument"


local SingleEmitter = require "Rx.emitter.single"
local Disposable = require "Rx.disposable"

--[[
    The emitter class that emits the signals on the receiver.
]]
local SingleCreateEmitter = class("SingleCreateEmitter", SingleEmitter, Disposable){
    new = function (self, observer)
        BadArgument(SingleObserver.instanceof(observer, SingleObserver), 1, "SingleObserver")

        self._observer = observer
    end,

    onSuccess = function (self, x)
        if(not isDisposed(self)) then 
            dispose(self)
            if(x == nil) then 
                observer:onError("onSuccess called with null. Null values are generally not allowed.")
            else 
                observer:onSuccess(x)
            end 
        end 
    end, 

    onError = function (self, t)
        if(not self:tryOnError(t)) then 
            error(t)
        end 
    end,

    tryOnError = function (self, t)
        if(t == nil) then 
            t = "onError called with null. Null values are generally not allowed."
        end
        if(not isDisposed(self)) then 
            local try, catch = pcall(function ()
                self._observer:onError(t)
            end)
            dispose(self)
            return true
        end
        return false
    end,

    setDisposable = function (self, disposable)
        BadArgument(Disposable.instanceof(disposable, Disposable), 1, "Disposable")

        set(self, disposable)
    end,

    dispose = function (self)
        dispose(self)
    end,

    isDisposed = function (self)
        return isDisposed(self)
    end,
}


local SingleCreate
local Single

local EmptySubscribe = SingleOnSubscribe(function () end)

local function produceSubscribe(sc)
    if(type(sc) == "function") then 
        return SingleOnSubscribe(sc)
    elseif(SingleOnSubscribe.instanceof(sc, SingleOnSubscribe)) then 
        return sc 
    elseif(sc == nil) then 
        return EmptySubscribe
    end 
    return false
end     
--[[
    Since the we require the Observable class and the Observable module requires this module,
    we need to asynchronously load the Observable class to prevent recursive requires
]]
local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "Rx.single"
        SingleCreate = class("SingleCreate", Single){
            new = function (self, source)
                source = produceSubscribe(source)
                BadArgument(source, 1, "SingleOnSubscribe, function or nil")
        
                self._source = source
            end, 
        
            subscribeActual = function (self, observer)
                BadArgument(SingleObserver.instanceof(observer, SingleObserver), 1, "SingleObserver")
        
                local parent = SingleCreateEmitter(observer)
                observer:onSubscribe(parent)
        
                local try, catch = pcall(function ()
                    self._source:subscribe(parent)
                end)
        
                if(not try) then 
                    parent:onError(catch)
                end 
            end 
        }
        
    end
end 

return function (source)
    source = produceSubscribe(source)
    BadArgument(source, 1, "SingleOnSubscribe, function or nil")
    asyncLoad()
    return SingleCreate(source)
end