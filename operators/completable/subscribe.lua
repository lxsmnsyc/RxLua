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

local CompletableObserver = require "RxLua.observer.completable"

local CallbackCompletableObserver = require "RxLua.observer.completable.callback"
local EmptyCompletableObserver = require "RxLua.observer.completable.empty"

local Action = require "RxLua.functions.action"

local ProduceAction = require "RxLua.functions.helper.produceAction"
local ProduceConsumer = require "RxLua.functions.helper.produceConsumer"

local BadArgument = require "RxLua.utils.badArgument"

return function (self, onComplete, onError, onSubscribe)
    local observer 
    if(CompletableObserver.instanceof(onComplete, CompletableObserver)) then 
        observer = onComplete 
    elseif(type(onComplete) == "function" or Action.instanceof(onComplete, Action)) then 
        onError = ProduceConsumer(onError)
        BadArgument(onError, 2, "Consumer, function or nil")
        observer = CallbackCompletableObserver(onComplete, onError)
    elseif(onComplete == nil) then 
        observer = EmptyCompletableObserver() 
    end 
    self:subscribeActual(observer)

    if(Disposable.instanceof(observer, Disposable)) then 
        return observer
    end
end 