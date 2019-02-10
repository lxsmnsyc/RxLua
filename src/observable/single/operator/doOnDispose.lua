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

local function emptyHandler() end 

return function (single, handler)
    assert(is(single), "TypeError: single must be a Single instance.")
    handler = type(handler) == "function" and handler or emptyHandler
    return Single(_, SingleOnSubscribe(_, function (emitter)
        --[[
            Subscribe to single
        ]]
        local disposable = subscribe(single, SingleObserver(_, {
            onSuccess = emitter.success,
            onError = emitter.error
        }))
        --[[
            modify cleanup
        ]]
        local cleanup = disposable.cleanup
        disposable.cleanup = function ()
            handler()
            cleanup()
        end
        --[[
            Return the disposable
        ]] 
        return disposable
    end))
end 