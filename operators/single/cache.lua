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

local get = require "RxLua.reference.get"
local set = require "RxLua.reference.set"
local compareAndSet = require "RxLua.reference.compareAndSet"
local getAndSet = require "RxLua.reference.getAndSet"
local getAndIncrement = require "RxLua.reference.getAndIncrement"


local SingleObserver = require "RxLua.observer.single"
local SingleSource = require "RxLua.source.single"

local Single 
local SingleCache 

local TERMINATED = {}

local function add(self, observer)
    local observers = self._observers
    while(1) do 
        local a = get(observers)
        if(a == TERMINATED) then 
            return false 
        end

        local b = {table.unpack(a)}
        b[#b + 1] = observer
        if(compareAndSet(observers, a, b)) then 
            return true
        end
    end 
end

local function remove(self, observer)
    local observers = self._observers
    while(1) do 
        local a = get(observers)
        local n = #a 
        if(n == 0) then 
            return 
        end 
        local j = 0
        for k, v in ipairs(a) do 
            if(v == observer) then 
                j = v 
                break
            end     
        end 

        if(j == 0) then 
            return 
        end 

        local b = {}
        if(n > 1) then 
            b = a 
            table.remove(a, j)
        end 
        if(compareAndSet(observer, a, b)) then 
            return  
        end
    end
end

local CacheDisposable = class("CacheDisposable", Disposable){
    new = function (self, actual, parent)
        self._downstream = actual 
        self._parent = parent
    end, 

    isDisposed = function (self)
        return get(self)
    end, 

    dispose = function (self)
        if(compareAndSet(self, nil, true)) then 
            remove(self._parent, self)
        end
    end, 
}

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"

        SingleCache = class("SingleCache", Single, SingleObserver){
            new = function (self, source)
                self._source = source 
                self._wip = {}
                
                local observers = {}
                set(observers, {})

                self._observers = observers 
            end,

            subscribeActual = function (self, observer)
                local d = CacheDisposable(observer, self)

                observer:onSubscribe(d)

                if(add(self, d)) then 
                    if(d:isDisposed()) then 
                        remove(self, d)
                    end 
                else 
                    local ex = self._error 
                    if(ex) then 
                        observer:onError(ex)
                    else 
                        observer:onSuccess(self._value)
                    end 
                    return
                end 

                if(getAndIncrement(self._wip) == 0) then 
                    self._source:subscribe(self)
                end 
            end,

            

            onSuccess = function (self, x)
                self._value = x 

                for k, v in ipairs(getAndSet(self._observers, TERMINATED)) do 
                    if(not v:isDisposed()) then 
                        v._downstream:onSuccess(x)
                    end 
                end 
            end,

            onError = function (self, t)
                self._error = t 

                for k, v in ipairs(getAndSet(self._observers, TERMINATED)) do 
                    if(not v:isDisposed()) then 
                        v._downstream:onError(t)
                    end 
                end
            end
        }
    end 
end 

return function (self)
    asyncLoad()
    return SingleCache(self)
end 