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

local SingleObserver = require "RxLua.observer.single"
local CompositeDisposable = require "RxLua.disposable.composite"

local incrementAndGet = require "RxLua.reference.incrementAndGet"
local compareAndSet = require "RxLua.reference.compareAndSet"
local get = require "RxLua.reference.get"

local EqualsSingleObserver = class("EqualsSingleObserver", SingleObserver){
    new = function (self, index, set, values, observer, count)
        self._index = index 
        self._set = set 
        self._values = values 
        self._downstream = observer 
        self._count = count 
    end, 

    onSubscribe = function (self, d)
        self._set:add(d)
    end, 

    onSuccess = function (self, x)
        local values = self._values
        values[self._index] = x

        if(incrementAndGet(self._count) == 2) then 
            self._downstream:onSuccess(values[1] == values[2])
        end 
    end,

    onError = function (self, t)
        while(1) do 
            local reference = self._count 
            local state = get(reference)
            if(state >= 2) then 
                return 
            end

            if(compareAndSet(reference, state, 2)) then 
                self._set:dispose()
                return
            end 
        end
    end 
}


local Single 
local SingleEquals

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleEquals = class("SingleEquals", Single){
            new = function (self, a, b)
                self._a = a 
                self._b = b
            end, 
            subscribeActual = function (self, observer)
                local set = CompositeDisposable()
                local count = {}
                local values = {}

                observer:onSubscribe(set)

                self._a:subscribe(EqualsSingleObserver(1, set, values, observer, count))
                self._b:subscribe(EqualsSingleObserver(2, set, values, observer, count))
            end
        }
    end 
end

local SingleSource = require "RxLua.source.single"
local BadArgument = require "RxLua.utils.badArgument"

return function (a, b)
    BadArgument(SingleSource.instanceof(a, SingleSource), 1, "SingleSource")
    BadArgument(SingleSource.instanceof(b, SingleSource), 2, "SingleSource")
    asyncLoad()
    return SingleEquals(a, b)
end