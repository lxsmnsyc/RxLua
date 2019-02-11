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


local Observer = require "Rx.observer"
local ObservableOnSubscribe = require "Rx.onSubscribe.observable"

local set = require "Rx.disposable.helper.set"
local dispose = require "Rx.disposable.helper.dispose"
local isDisposed = require "Rx.disposable.helper.isDisposed"

local BadArgument = require "Rx.utils.badArgument"


local ObservableEmitter = require "Rx.emitter.observable"
local Disposable = require "Rx.disposable"
--[[
    The emitter class that emits the signals on the receiver.
]]
local ObservableCreateEmitter = class("ObservableCreateEmitter", ObservableEmitter, Disposable){
    new = function (self, observer)
        BadArgument(Observer.instanceof(observer, Observer), 1, "Observer")

        self._observer = observer
    end,

    onNext = function (self, x)
        if(x == nil) then 
            self:onError("onNext called with null. Null values are generally not allowed.")
            return
        end 

        if(not self:isDisposed()) then
            self._observer:onNext(x)
        end
    end, 

    onError = function (self, t)
        if(not self:tryOnError(t)) then 
            error(t)
        end 
    end,

    tryOnError = function (self, t)
        if(t == nil) then 
            t = "onNext called with null. Null values are generally not allowed."
        end
        if(not self:isDisposed()) then 
            local try, catch = pcall(function ()
                self._observer:onError(t)
            end)
            self:dispose()
            return true
        end
        return false
    end,

    onComplete = function (self)
        if(not self:isDisposed()) then 
            local try, catch = pcall(function ()
                self._observer:onComplete()
            end)
            self:dispose()
        end
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


local ObservableCreate
local Observable

local EmptySubscribe = ObservableOnSubscribe(function () end)

local function produceSubscribe(sc)
    if(type(sc) == "function") then 
        return ObservableOnSubscribe(sc)
    elseif(ObservableOnSubscribe.instanceof(sc, ObservableOnSubscribe)) then 
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
        Observable = require "Rx.observable"
        ObservableCreate = class("ObservableCreate", Observable){
            new = function (self, source)
                source = produceSubscribe(source)
                BadArgument(source, 1, "CompletableOnSubscribe, function or nil")
        
                self._source = source
            end, 
        
            subscribeActual = function (self, observer)
                BadArgument(Observer.instanceof(observer, Observer), 1, "Observer")
        
                local parent = ObservableCreateEmitter(observer)
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
    BadArgument(source, 1, "CompletableOnSubscribe, function or nil")
    asyncLoad()
    return ObservableCreate(source)
end