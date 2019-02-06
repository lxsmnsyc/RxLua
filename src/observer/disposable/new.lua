local M = require "RxLua.src.observer.disposable.M"

local Disposable = require "RxLua.src.disposable.new"
local dispose = require "RxLua.src.disposable.dispose"

return function (_, receiver)
    assert(type(receiver) == "table", "TypeError: receiver is not a table. (received: "..type("receiver")..")")

    local disposable = Disposable()

    local onStart = receiver.onStart
    local onNext = receiver.onNext 
    local onError = receiver.onError 
    local onComplete = receiver.onComplete 
    local onSubscribe = receiver.onSubscribe

    local recognizeStart = type(onStart) == "function"
    local recognizeNext = type(onNext) == "function"
    local recognizeError = type(onError) == "function"
    local recognizeComplete = type(onComplete) == "function"
    local recognizeSubscribe = type(onSubscribe) == "function"

    local function internalDispose()
        dispose(disposable)
    end 

    local function isDisposed()
        return disposable.isDisposed
    end 

    local function startHandler()
        if(not disposable.isDisposed and recognizeStart) then 
            onStart()
        end 
    end 
    
    local function nextHandler(x)
        if(not disposable.isDisposed and recognizeNext) then 
            onNext(x, internalDispose, isDisposed)
        end 
    end 

    local function errorHandler(err)
        if(not disposable.isDisposed) then 
            dispose(disposable)
            if(recognizeError) then 
                onError(err)
            end
        end 
    end 

    local function completeHandler()
        if(not disposable.isDisposed) then 
            dispose(disposable)
            if(recognizeComplete) then 
                onComplete()
            end
        end 
    end 

    local function subscribeHandler(d)
        local cleanup = disposable.cleanup
        disposable.cleanup = function ()
            cleanup()

            dispose(d)
        end
        if(not disposable.isDisposed and recognizeSubscribe) then 
            onSubscribe(d)
        end 
    end

    return setmetatable({
        onStart = startHandler,
        onNext = nextHandler,
        onError = errorHandler,
        onComplete = completeHandler,
        onSubscribe = subscribeHandler,
        _disposable = disposable,
        _className = "DisposableObserver"
    }, M)
end