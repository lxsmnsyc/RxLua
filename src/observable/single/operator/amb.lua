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

local Single = require "RxLua.src.observable.single.new"
local is = require "RxLua.src.observable.single.is"
local subscribe = require "RxLua.src.observable.single.subscribe"

local SingleOnSubscribe = require "RxLua.src.onSubscribe.single.new"

local SingleObserver = require "RxLua.src.observer.single.new"
local isSingleEmitterDisposed = require "RxLua.src.emitter.single.isDisposed"

local CompositeDisposable = require "RxLua.src.disposable.composite.new"
local compositeAdd = require "RxLua.src.disposable.composite.add"
local compositeDelete = require "RxLua.src.disposable.composite.delete"
local disposeComposite = require "RxLua.src.disposable.composite.dispose"

return function (...)
    --[[
        Get the sources
    ]]
    local sources = {...}
    --[[
        Make sure that all source are Singles
    ]]
    for k, single in ipairs(sources) do 
        assert(is(single), "TypeError: Argument #"..k.." must be a Single.")
    end 
    --[[
        return the Single
    ]]
    return Single(_, SingleOnSubscribe(_, function (emitter)
        --[[
            Create a CompositeDisposable that disposes all
            Disposables returned by every subscription
        ]]
        local composite = CompositeDisposable()

        for k, single in ipairs(sources) do 
            --[[
                Subscribe to the single
            ]]
            local disposable 
            
            subscribe(single, SingleObserver(_, {
                onSubscribe = function (d)
                    --[[
                        add disposable to composite
                    ]]
                    disposable = d
                    compositeAdd(composite, d)
                end,
                onSuccess = function (x)
                    compositeDelete(composite, disposable)
                    disposeComposite(composite)
                    emitter.success(x)
                end,
                onError = function (x)
                    compositeDelete(composite, disposable)
                    disposeComposite(composite)
                    emitter.error(x)
                end
            }))
            --[[
                Check if emitter is disposed
            ]]
            if(isSingleEmitterDisposed(emitter)) then 
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