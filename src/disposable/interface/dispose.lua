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
local isDisposed = require "RxLua.src.disposable.interface.isDisposed"

--[[
    Load the dispose function variants
]]
local Disposable = require "RxLua.src.disposable.dispose"
local CompositeDisposable = require "RxLua.src.disposable.composite.dispose"
local DisposableObserver = require "RxLua.src.observer.disposable.dispose"
local DisposableMaybeObserver = require "RxLua.src.observer.maybe.disposable.dispose"
local DisposableCompletableObserver = require "RxLua.src.observer.completable.disposable.dispose"
local DisposableSingleObserver = require "RxLua.src.observer.single.disposable.dispose"

local ObservableEmitter = require "RxLua.src.emitter.observable.dispose"
local MaybeEmitter = require "RxLua.src.emitter.maybe.dispose"
local CompletableEmitter = require "RxLua.src.emitter.completable.dispose"
local SingleEmitter = require "RxLua.src.emitter.single.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

return function (disposable)
    --[[
        Check argument
    ]]
    local context = debug.getinfo(1).name
    badArgument(isDisposable(disposable), 1, context, "Disposable")
    --[[
        Disposable is already disposed, exit.
    ]]
    if(isDisposed(disposable)) then 
        return false 
    end
    --[[
        Dispose
    ]]
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