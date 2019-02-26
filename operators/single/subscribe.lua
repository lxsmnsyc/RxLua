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

local Disposable = require "RxLua.disposable"

local SingleObserver = require "RxLua.observer.single"

local BiConsumerSingleObserver = require "RxLua.observer.single.biconsumer"
local ConsumerSingleObserver = require "RxLua.observer.single.consumer"

local BiConsumer = require "RxLua.functions.biconsumer"

local ProduceConsumer = require "RxLua.functions.helper.produceConsumer"

local BadArgument = require "RxLua.utils.badArgument"

return function (self, onSuccess, onError)
    local observer 
    if(SingleObserver.instanceof(onSuccess, SingleObserver)) then 
        observer = onSuccess 
    elseif(BiConsumer.instanceof(onSuccess, BiConsumer)) then
        observer = BiConsumerSingleObserver(onSuccess)
    else 
        onSuccess = ProduceConsumer(onSuccess)
        onError = ProduceConsumer(onError)

        BadArgument(onSuccess, 1, "Consumer, function or nil")
        BadArgument(onError, 2, "Consumer, function or nil")
        
        observer = ConsumerSingleObserver(onSuccess, onError)
    end 
    self:subscribeActual(observer)
    if(Disposable.instanceof(observer, Disposable)) then 
        return observer
    end
end 