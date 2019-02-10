--[[
    Reactive Extensions
	
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

local Observable = require "RxLua.src.observable.new"
local is = require "RxLua.src.observable.is"
local subscribe = require "RxLua.src.observable.subscribe"

local ObservableOnSubscribe = require "RxLua.src.onSubscribe.observable.new"

local Observer = require "RxLua.src.observer.new"
local isObservableEmitterDisposed = require "RxLua.src.emitter.single.isDisposed"

local CompositeDisposable = require "RxLua.src.disposable.composite.new"
local compositeAdd = require "RxLua.src.disposable.composite.add"
local disposeComposite = require "RxLua.src.disposable.composite.dispose"

return function (...)
    --[[
        Get the sources
    ]]
    local sources = {...}
    --[[
        Make sure that all source are Singles
    ]]
    for k, observable in ipairs(sources) do 
        assert(is(observable), "TypeError: Argument #"..k.." must be an Observable.")
    end 
    --[[
        return the Single
    ]]
    return Observable(_, ObservableOnSubscribe(_, function (emitter)
        --[[
            Create a CompositeDisposable that disposes all
            Disposables returned by every subscription
        ]]
        local composite = CompositeDisposable()

        local firstObservable 
        for k, observable in ipairs(sources) do 
            --[[
                Subscribe to the single
            ]]
            local disposable 
            subscribe(observable, Observer(_, {
                onSubscribe = function (d)
                    --[[
                        add disposable to composite
                    ]]
                    disposable = d
                    compositeAdd(composite, d)
                end,
                onNext = function (x)
                    if(isObservableEmitterDisposed(emitter)) then 
                        disposeComposite(composite)
                    else
                        if(not firstObservable) then
                            firstObservable = observable
                        end

                        if(firstObservable and firstObservable == observable) then 
                            emitter.next(x)
                        end 
                    end
                end,
                onError = function (x)
                    compositeDelete(composite, disposable)
                    disposeComposite(composite)
                    emitter.error(x)
                end,
                onComplete = function ()
                    compositeDelete(composite, disposable)
                    disposeComposite(composite)
                    emitter.complete()
                end
            }))
            --[[
                Check if emitter is disposed
            ]]
            if(isObservableEmitterDisposed(emitter)) then 
                --[[
                    Dispose Composite
                ]]
                disposeComposite(composite)
                return
            end 
        end 
        --[[
            Return composite
        ]]
        return composite
    end))
end 