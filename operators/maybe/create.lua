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


local MaybeObserver = require "RxLua.observer.maybe"
local MaybeOnSubscribe = require "RxLua.onSubscribe.maybe"

local set = require "RxLua.disposable.helper.set"
local dispose = require "RxLua.disposable.helper.dispose"
local isDisposed = require "RxLua.disposable.helper.isDisposed"

local BadArgument = require "RxLua.utils.badArgument"


local MaybeEmitter = require "RxLua.emitter.maybe"
local Disposable = require "RxLua.disposable"

--[[
    The emitter class that emits the signals on the receiver.
]]

local function tryOnError(self, t)
end

local MaybeCreateEmitter = class("MaybeCreateEmitter", MaybeEmitter, Disposable){
    new = function (self, observer)
        self._observer = observer
    end,

    onSuccess = function (self, x)
        if(not isDisposed(self)) then 
            dispose(self)
            if(x == nil) then 
                self._observer:onError("onSuccess called with null. Null values are generally not allowed.")
            else 
                self._observer:onSuccess(x)
            end 
        end 
    end, 

    onError = function (self, t)
        if(t == nil) then 
            t = "onError called with null. Null values are generally not allowed."
        end
        if(not isDisposed(self)) then 
            dispose(self)
            self._observer:onError(t)
        end
    end,

    onComplete = function (self)
        if(not isDisposed(self)) then
            dispose(self)
            self._observer:onComplete()
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


local MaybeCreate
local Maybe

local EmptySubscribe = MaybeOnSubscribe(function () end)

local function produceSubscribe(sc)
    if(type(sc) == "function") then 
        return MaybeOnSubscribe(sc)
    elseif(MaybeOnSubscribe.instanceof(sc, MaybeOnSubscribe)) then 
        return sc 
    elseif(sc == nil) then 
        return EmptySubscribe
    end 
    return false
end     
--[[
    Since the we require the Maybe class and the Maybe module requires this module,
    we need to asynchronously load the Maybe class to prevent recursive requires
]]
local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Maybe = require "RxLua.maybe"
        MaybeCreate = class("MaybeCreate", Maybe){
            new = function (self, source)
                source = produceSubscribe(source)
                BadArgument(source, 1, "MaybeOnSubscribe, function or nil")
        
                self._source = source
            end, 
        
            subscribeActual = function (self, observer)
                BadArgument(MaybeObserver.instanceof(observer, MaybeObserver), 1, "MaybeObserver")
        
                local parent = MaybeCreateEmitter(observer)
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
    BadArgument(source, 1, "MaybeOnSubscribe, function or nil")
    asyncLoad()
    return MaybeCreate(source)
end