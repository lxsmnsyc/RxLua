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

--[[
    Load all is variants
]]
local Disposable = require "RxLua.src.disposable.is"
local CompositeDisposable = require "RxLua.src.disposable.composite.is"

local DisposableObserver = require "RxLua.src.observer.disposable.is"
local DisposableMaybeObserver = require "RxLua.src.observer.maybe.disposable.is"
local DisposableCompletableObserver = require "RxLua.src.observer.completable.disposable.is"
local DisposableSingleObserver = require "RxLua.src.observer.single.disposable.is"

local ObservableEmitter = require "RxLua.src.emitter.observable.is"
local MaybeEmitter = require "RxLua.src.emitter.maybe.is"
local CompletableEmitter = require "RxLua.src.emitter.completable.is"
local SingleEmitter = require "RxLua.src.emitter.single.is"

return function (disposable)
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
end