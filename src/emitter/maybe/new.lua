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

local M = require "RxLua.src.emitter.maybe.M"
local badArgument = require "RxLua.src.asserts.badArgument"

local isObserver = require "RxLua.src.observer.maybe.interface.is"

local isDisposable = require "RxLua.src.disposable.interface.is"
local isDisposed = require "RxLua.src.disposable.interface.isDisposed"
local dispose = require "RxLua.src.disposable.interface.dispose"

return function (_, observer)
    badArgument(
        isObserver(observer), 
        1, debug.getinfo(1).name, "implements MaybeObserverInterface"
    )
    return setmetatable({
        _className = "MaybeEmitter",

        success = observer.onSuccess,
        error = observer.onError,
        complete = observer.onComplete
        
    }, M)
end