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
local is = require "RxLua.src.observable.completable.is"

local isObserver = require "RxLua.src.observer.completable.interface.is"

local Disposable = require "RxLua.src.disposable.new"

local isDisposable = require "RxLua.src.disposable.interface.is"
local dispose = require "RxLua.src.disposable.interface.dispose"

local CallbackCompletableObserver = require "RxLua.src.observer.completable.callback.new"
local EmptyCompletableObserver = require "RxLua.src.observer.completable.empty.new"

local CompletableEmitter = require "RxLua.src.emitter.completable.new"

local subscribe = require "RxLua.src.onSubscribe.completable.subscribe"

return function (observable, onComplete, onError)
    local observer 
    --[[
        If onComplete is a valid CompletableObservable, continue
    ]]
    if(isObserver(onComplete)) then 
        observer = onComplete
    --[[
        If onComplete is a function, create a CallbackCompletableObserver
    ]]
    elseif(type(onComplete) == "function") then 
        observer = CallbackCompletableObserver(_, onComplete, onError)
    else
    --[[
        Otherwise, create an EmptyCompletableObserver
    ]]
        observer = EmptyCompletableObserver()
    end 

    local disposable = Disposable()

    local try, obs = pcall(function ()
        observer = observable._modify(observer)
    end)

    if(try) then 
        local emitter = CompletableEmitter(_, observer)

        emitter:setDisposable(disposable)

        local onSubscribe = observer.onSubscribe
        if(onSubscribe) then 
            onSubscribe(disposable)
        end 

        local status, result = pcall(function ()
            return subscribe(observable._subscriber, emitter)
        end)

        if(status) then 
            if(isDisposable(result)) then 
                disposable.cleanup = function ()
                    dispose(disposable)
                end 
            elseif(type(result) == "function") then 
                disposable.cleanup = result
            end 
        else 
            observer.onError(result)
            error(result)
            dispose(disposable)
        end 
    else 
        observer.onError(obs)
        error(result)
        dispose(disposable)
    end

    return disposable
end 
