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
local Maybe = require "RxLua.src.observable.maybe.new"
local MaybeOnSubscribe = require "RxLua.src.onSubscribe.maybe.new"

local is = require "RxLua.src.observable.single.is"
local subscribe = require "RxLua.src.observable.single.subscribe"
local SingleObserver = require "RxLua.src.observer.single.new"

local function emptyCriteria() return true end

return function (single, criteria)
    assert(is(single), "TypeError: single must be a Single instance.")
    criteria = (type(criteria) == "function" and criteria) or emptyCriteria
    return Maybe(_, MaybeOnSubscribe(_, function (emitter)
        return subscribe(single, SingleObserver(_, {
            onSuccess = function (x)
                local status, result = pcall(function ()
                    return criteria(x)
                end)
                if(status) then 
                    if(result) then 
                        emitter.success(x)
                    else 
                        emitter.complete()
                    end 
                else 
                    emitter.error(result)
                end 
            end,
            onError = emitter.error
        }))
    end))
end