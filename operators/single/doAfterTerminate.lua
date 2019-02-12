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
local Disposable = require "RxLua.disposable"

local Action = require "RxLua.functions.action"

local validate = require "RxLua.disposable.helper.validate"

local DATSingleObserver = class("DATSingleObserver", SingleObserver, Disposable){
    new = function (self, downstream, actual)
        self._downstream = downstream
        self._actual = actual
    end, 

    dispose = function (self)
        self._upstream:dispose()
    end,
    isDisposed = function ()
        return self._upstream:isDisposed()
    end,

    onSuccess = function (self, x)
        self._downstream:onSuccess(x)
        self._actual:run()
    end,
    onError = function (self, t)
        self._downstream:onError(t)
        self._actual:run()
    end,

    onSubscribe = function (self, d)
        if(validate(self._upstream, d)) then 
            self._upstream = d
            self._downstream:onSubscribe(self)
        end 
    end
}

local Single 
local SingleDoAfterTerminate


local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleDoAfterTerminate = class("SingleDoAfterTerminate", Single){
            new = function (self, source, actual)
                self._source = source 
                self._actual = actual
            end, 
            subscribeActual = function (self, observer)
                self._source:subscribe(DATSingleObserver(observer, self._actual))
            end, 
        }
    end 
end

local BadArgument = require "RxLua.utils.badArgument"

return function (source, afterTerminate)
    if((not Action.instanceof(afterTerminate, Action)) and type(afterTerminate) == "function") then 
        afterTerminate = Action(afterTerminate)
    else 
        BadArgument(false, 1, "Action or function")
    end
    asyncLoad()
    return SingleDoAfterTerminate(source, afterTerminate)
end