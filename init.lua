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
local Rx = {}

local moduleName = "RxLua.src"

local function load(name)
    return require(moduleName.."."..name)
end

Rx.Interface = load("interface")

--[[
    Disposable
]]
Rx.DisposableInterface = load("disposable.interface")

Rx.Disposable = load("disposable")
Rx.CompositeDisposable = load("disposable.composite")
Rx.EmptyDisposable = load("disposable.empty")
--[[
    Observer
]]
Rx.ObserverInterface = load("observer.interface")
Rx.Observer = load("observer")
Rx.DisposableObserver = load("observer.disposable")
Rx.DefaultObserver = load("observer.default")
Rx.LambdaObserver = load("observer.lambda")

Rx.MaybeObserverInterface = load("observer.maybe.interface")
Rx.MaybeObserver = load("observer.maybe")
Rx.DisposableMaybeObserver = load("observer.maybe.disposable")
Rx.CallbackMaybeObserver = load("observer.maybe.callback")

Rx.SingleObserverInterface = load("observer.single.interface")
Rx.SingleObserver = load("observer.single")
Rx.DisposableSingleObserver = load("observer.single.disposable")
Rx.ConsumerSingleObserver = load("observer.single.consumer")
Rx.BiConsumerSingleObserver = load("observer.single.biconsumer")

Rx.CompletableObserverInterface = load("observer.completable.interface")
Rx.CompletableObserver = load("observer.completable")
Rx.DisposableCompletableObserver = load("observer.completable.disposable")
Rx.EmptyCompletableObserver = load("observer.completable.empty")
Rx.CallbackCompletableObserver = load("observer.completable.callback")

--[[
    Emitter
]]
Rx.ObservableEmitter = load("emitter.observable")
Rx.MaybeEmitter = load("emitter.maybe")
Rx.CompletableEmitter = load("emitter.completable")
Rx.SingleEmitter = load("emitter.single")

--[[
    OnSubscribe
]]
Rx.ObservableOnSubscribe = load("onSubscribe.observable")
Rx.MaybeOnSubscribe = load("onSubscribe.maybe")
Rx.CompletableOnSubscribe = load("onSubscribe.completable")
Rx.SingleOnSubscribe = load("onSubscribe.single")

--[[
    Functions
]]
Rx.Action = load("functions.action")
Rx.Consumer = load("functions.consumer")
Rx.BiConsumer = load("functions.biconsumer")
--[[
    Observable
]]
Rx.Observable = load("observable")
Rx.Maybe = load("observable.maybe")
Rx.Completable = load("observable.completable")
Rx.Single = load("observable.single")
return Rx