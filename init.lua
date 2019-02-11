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

Rx.Class = require "Rx.utils.meta.class"

Rx.Disposable = require "Rx.disposable"
Rx.CompositeDisposable = require "Rx.disposable.composite"

Rx.Action = require "Rx.functions.action"
Rx.Consumer = require "Rx.functions.consumer"
Rx.BiConsumer = require "Rx.functions.biconsumer"
Rx.Predicate = require "Rx.functions.predicate"
Rx.BiPredicate = require "Rx.functions.predicate"
Rx.PolyFunction = require "Rx.functions.polyfunction"

Rx.Observer = require "Rx.observer"
Rx.DefaultObserver = require "Rx.observer.default"
Rx.DisposableObserver = require "Rx.observer.disposable"
Rx.LambdaObserver = require "Rx.observer.lambda"
Rx.DisposableLambdaObserver = require "Rx.observer.lambda.disposable"

Rx.CompletableObserver = require "Rx.observer.completable"
Rx.CallbackCompletableObserver = require "Rx.observer.completable.callback"
Rx.EmptyCompletableObserver = require "Rx.observer.completable.empty"
Rx.DisposableCompletableObserver = require "Rx.observer.completable.disposable"

Rx.MaybeObserver = require "Rx.observer.maybe"
Rx.DisposableMaybeObserver = require "Rx.observer.maybe"

Rx.SingleObserver = require "Rx.observer.single"
Rx.DisposableSingleObserver = require "Rx.observer.single.disposable"
Rx.ResumeSingleObserver = require "Rx.observer.single.resume"
Rx.ConsumerSingleObserver = require "Rx.observer.single.consumer"
Rx.BiConsumerSingleObserver = require "Rx.observer.single.biconsumer"

Rx.Emitter = require "Rx.emitter"
Rx.ObservableEmitter = require "Rx.emitter.observable"
Rx.CompletableEmitter = require "Rx.emitter.completable"
Rx.MaybeEmitter = require "Rx.emitter.maybe"
Rx.SingleEmitter = require "Rx.emitter.single"

Rx.ObservableOnSubscribe = require "Rx.onSubscribe.observable"
Rx.CompletableOnSubscribe = require "Rx.onSubscribe.completable"
Rx.MaybeOnSubscribe = require "Rx.onSubscribe.maybe"
Rx.SingleOnSubscribe = require "Rx.onSubscribe.single"

Rx.ObservableSource = require "Rx.source.observable"
Rx.CompletableSource = require "Rx.source.completable"
Rx.MaybeSource = require "Rx.source.maybe"
Rx.SingleSource = require "Rx.source.single"

Rx.Observable = require "Rx.observable"
Rx.Completable = require "Rx.completable"
Rx.Maybe = require "Rx.maybe"
Rx.Single = require "Rx.single"

return Rx