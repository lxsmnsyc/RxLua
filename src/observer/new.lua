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

local M = require "RxLua.src.observer.M"

return function (_, receiver)
    assert(type(receiver) == "table", "TypeError: receiver is not a table. (received: "..type("receiver")..")")
    --[[
        Tells the observer that it can receive signals
    ]]
    local active = true 

    local onNext = receiver.onNext 
    local onError = receiver.onError
    local onComplete = receiver.onComplete
    local onSubscribe = receiver.onSubscribe
    
    local recognizeNext = type(onNext) == "function"
    local recognizeError = type(onError) == "function"
    local recognizeComplete = type(onComplete) == "function"
    local recognizeSubscribe = type(onSubscribe) == "function"

    local function nextHandler(x)
        if(active and recognizeNext) then 
            onNext(x)
        end 
    end 
    
    local function errorHandler(err)
        if(active) then 
            active = false
            if(recognizeError) then 
                onError(err)
            end
        end 
    end 

    local function completeHandler()
        if(active) then 
            active = false
            if(recognizeComplete) then 
                onComplete()
            end
        end 
    end 

    local function subscribeHandler(d)
        if(active and recognizeSubscribe) then 
            onSubscribe(d)
        end 
    end 

    return setmetatable({
        onNext = nextHandler,
        onError = errorHandler,
        onComplete = completeHandler,
        onSubscribe = subscribeHandler,
        _className = "Observer"
    }, M)
end 