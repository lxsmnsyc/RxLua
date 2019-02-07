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
local isDisposable = require "RxLua.src.disposable.interface.is"
--[[
    Load all is variants
]]
local Disposable = require "RxLua.src.disposable.isDisposed"
local CompositeDisposable = require "RxLua.src.disposable.composite.isDisposed"

local DisposableObserver = require "RxLua.src.observer.disposable.isDisposed"
local DisposableMaybeObserver = require "RxLua.src.observer.maybe.disposable.isDisposed"
local DisposableCompletableObserver = require "RxLua.src.observer.completable.disposable.isDisposed"
local DisposableSingleObserver = require "RxLua.src.observer.single.disposable.isDisposed"

local ObservableEmitter = require "RxLua.src.emitter.observable.isDisposed"
local MaybeEmitter = require "RxLua.src.emitter.maybe.isDisposed"
local CompletableEmitter = require "RxLua.src.emitter.completable.isDisposed"
local SingleEmitter = require "RxLua.src.emitter.single.isDisposed"

return function (x)
    --[[
        Check argument
    ]]
    local context = debug.getinfo(1).name
    badArgument(isDisposable(x), 1, context, "Disposable")
    
    local status, result = pcall(function ()
        return Disposable(disposable)
            or CompositeDisposable(disposable)
            or DisposableObserver(disposable)
            or DisposableMaybeObserver(disposable)
            or DisposableCompletableObserver(disposable)
            or DisposableSingleObserver(disposable)
            or ObservableEmitter(disposable)
            or MaybeEmitter(disposable)
            or CompletableEmitter(disposable)
            or SingleEmitter(disposable)
    end)

    if(status) then 
        return result 
    end 
    return false
end