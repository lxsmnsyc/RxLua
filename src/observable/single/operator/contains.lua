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

local dispose = require "RxLua.src.disposable.dispose"

local function defaultPredicate(a, b)
    return a == b
end 

return function (single, value, bipredicate)
    --[[
        If the bipredicate is not a function, fallback to defaultPredicate
    ]]
    bipredicate = type(bipredicate) == "function" and bipredicate or defaultPredicate
    return Single(_, SingleOnSubscribe(_, function (emitter)
        --[[
            Subscribe to single
        ]]
        return subscribe(single, SingleObserver(_, {
            onSuccess = function (x)
                --[[
                    Try comparing the value
                ]]
                local status, result = pcall(function ()
                    return bipredicate(value, x)
                end)
                --[[
                    Check if no errors
                ]]
                if(status) then 
                    if(result) then 
                        --[[
                            emit if equality passed
                        ]]
                        emitter.success(true)
                    else 
                        emitter.success(false)
                    end
                else 
                    --[[
                        emit error caused by predicate
                    ]]
                    emitter.error(result)
                end
            end,
            onError = emitter.error
        }))
    end))
end 