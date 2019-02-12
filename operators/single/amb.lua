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
local SingleSource = require "RxLua.source.single"

local CompositeDisposable = require "RxLua.disposable.composite"

local compareAndSet = require "RxLua.reference.compareAndSet"

local BadArgument = require "RxLua.utils.badArgument"

local AmbSingleObserver = class("AmbSingleObserver", SingleObserver){
    new = function (self, once, set, observer)
        self._once = once 
        self._set = set 
        self._downstream = observer
    end,

    onSubscribe = function (self, d)
        self._upstream = d 
        self._set:add(d)
    end, 

    onSuccess = function (self, x)
        if(compareAndSet(self._once, nil, true)) then 
            local set = self._set 
            set:delete(self._upstream)
            set:dispose()

            self._downstream:onSuccess(x)
        end
    end,

    onError = function (self, t)
        if(compareAndSet(self._once, nil, true)) then 
            local set = self._set 
            set:delete(self._upstream)
            set:dispose()

            self._downstream:onError(t)
        end
    end 
}


local Single
local SingleAmb 

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleAmb = class("SingleAmb", Single){
            new = function (self, sources)
                self._sources = sources
            end,
            subscribeActual = function (self, observer)
                local sources = self._sources 
                local winner = {}
                local set = CompositeDisposable()

                observer:onSubscribe(set)

                for k, source in ipairs(sources) do 
                    if(set:isDisposed()) then 
                        return 
                    end 

                    source:subscribe(AmbSingleObserver(winner, set, observer))
                end 
            end 
        }
    end 
end 

return function (sources)
    for k, v in ipairs(sources) do 
        BadArgument(SingleSource.instanceof(v, SingleSource), 1, "table of SingleSource")
    end 
    asyncLoad()
    return SingleAmb(sources)
end 