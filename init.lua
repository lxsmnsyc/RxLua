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

local RxLua = {}

RxLua.Class = require "RxLua.utils.meta.class"
RxLua.Reference = require "RxLua.reference"

RxLua.Disposable = require "RxLua.disposable"
RxLua.CompositeDisposable = require "RxLua.disposable.composite"

RxLua.Action = require "RxLua.functions.action"
RxLua.Consumer = require "RxLua.functions.consumer"
RxLua.BiConsumer = require "RxLua.functions.biconsumer"
RxLua.Predicate = require "RxLua.functions.predicate"
RxLua.BiPredicate = require "RxLua.functions.predicate"
RxLua.PolyFunction = require "RxLua.functions.polyfunction"

RxLua.Observer = require "RxLua.observer"
RxLua.DefaultObserver = require "RxLua.observer.default"
RxLua.DisposableObserver = require "RxLua.observer.disposable"
RxLua.LambdaObserver = require "RxLua.observer.lambda"
RxLua.DisposableLambdaObserver = require "RxLua.observer.lambda.disposable"

RxLua.CompletableObserver = require "RxLua.observer.completable"
RxLua.CallbackCompletableObserver = require "RxLua.observer.completable.callback"
RxLua.EmptyCompletableObserver = require "RxLua.observer.completable.empty"
RxLua.DisposableCompletableObserver = require "RxLua.observer.completable.disposable"

RxLua.MaybeObserver = require "RxLua.observer.maybe"
RxLua.DisposableMaybeObserver = require "RxLua.observer.maybe"

RxLua.SingleObserver = require "RxLua.observer.single"
RxLua.DisposableSingleObserver = require "RxLua.observer.single.disposable"
RxLua.ResumeSingleObserver = require "RxLua.observer.single.resume"
RxLua.ConsumerSingleObserver = require "RxLua.observer.single.consumer"
RxLua.BiConsumerSingleObserver = require "RxLua.observer.single.biconsumer"

RxLua.Emitter = require "RxLua.emitter"
RxLua.ObservableEmitter = require "RxLua.emitter.observable"
RxLua.CompletableEmitter = require "RxLua.emitter.completable"
RxLua.MaybeEmitter = require "RxLua.emitter.maybe"
RxLua.SingleEmitter = require "RxLua.emitter.single"

RxLua.ObservableOnSubscribe = require "RxLua.onSubscribe.observable"
RxLua.CompletableOnSubscribe = require "RxLua.onSubscribe.completable"
RxLua.MaybeOnSubscribe = require "RxLua.onSubscribe.maybe"
RxLua.SingleOnSubscribe = require "RxLua.onSubscribe.single"

RxLua.ObservableSource = require "RxLua.source.observable"
RxLua.CompletableSource = require "RxLua.source.completable"
RxLua.MaybeSource = require "RxLua.source.maybe"
RxLua.SingleSource = require "RxLua.source.single"

RxLua.Observable = require "RxLua.observable"
RxLua.Completable = require "RxLua.completable"
RxLua.Maybe = require "RxLua.maybe"
RxLua.Single = require "RxLua.single"

return RxLua