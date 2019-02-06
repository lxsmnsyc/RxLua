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
local is = require "RxLua.src.observable.maybe.is"

local Disposable = require "RxLua.src.disposable.new"
local isDisposable = require "RxLua.src.disposable.is"
local disposeDisposable = require "RxLua.src.disposable.dispose"

local isCompositeDisposable = require "RxLua.src.disposable.composite.is"
local disposeCompositeDisposable = require "RxLua.src.disposable.composite.dispose"

local disposeDisposableObserver = require "RxLua.src.observer.maybe.disposable.dispose"

local MaybeEmitter = require "RxLua.src.emitter.maybe.new"
local setDisposable = require "RxLua.src.emitter.maybe.setDisposable"

local isOnSubscribe = require "RxLua.src.onSubscribe.maybe.is"
local subscribe = require "RxLua.src.onSubscribe.maybe.subscribe"

local isObserver = require "RxLua.src.observer.maybe.is"
local isDisposableObserver = require "RxLua.src.observer.maybe.disposable.is"

local function emptyHandler() end

return function (maybe, observer)
    assert(is(maybe), "TypeError: maybe must be a Maybe instance.")

    local disposableObserver = isDisposableObserver(observer)
    --[[
        Check if observer is a valid Maybe observer
    ]]
    assert(
        observer and (isObserver(observer) or disposableObserver), 
        "TypeError: observer must be either a MaybeObserver or a DisposableMaybeObserver instance."
    )

    local subscriber = observable._subscriber 
    --[[
        Check if subscriber is an MaybeOnSubscribe instance
    ]]
    if(subscriber and isOnSubscribe(subscriber)) then 
        --[[
            Create the disposable
        ]]
        local disposable = Disposable()
        --[[
            Create the emitter
        ]]
        local emitter = MaybeEmitter(_, {
            onSuccess = observer.onSuccess, 
            onError = observer.onError,
            onComplete = observer.onComplete
        })
        --[[
            Set the disposable for the emitter
        ]]
        setDisposable(emitter, disposable)

        --[[
            Run handlers
        ]]
        local onSubscribe = observer.onSubscribe

        if(type(onSubscribe) == "function") then 
            onSubscribe(disposable)
        end 

        --[[
            If the observer is a DisposableMaybeObserver instance,
            run the onStart handler
        ]]
        if(disposableObserver) then 
            local onStart = observer.onStart 
            if(type(onStart) == "function") then 
                onStart()
            end 
        end 
        --[[
            Run the OnSubscribe
        ]]
        local status, result = pcall(function ()
            return subscribe(subscriber, emitter)
        end)
        --[[
            Customize the cleanup for the disposable
        ]]
        if(status) then 
            if(result) then 
                local cleanup = emptyHandler
                --[[
                    Check if the received result is a Disposable
                ]]
                if(isDisposable(result)) then 
                    cleanup = function ()
                        disposeDisposable(result)
                    end 
                --[[
                    or a CompositeDisposable
                ]]
                elseif(isCompositeDisposable(result)) then 
                    cleanup = function ()
                        disposeCompositeDisposable(result)
                    end 
                --[[
                    or a function
                ]]
                elseif(type(result) == "function") then
                    cleanup = result
                end 

                --[[
                    Dispose the observer if it is a DisposableMaybeObserver
                ]]
                if(disposableObserver) then 
                    disposable.cleanup = function ()
                        cleanup()

                        disposeDisposableObserver(observer)
                    end 
                end
            end 
            return disposable
        else 
            local onError = observer.onError 
            if(type(onError) == "function") then 
                onError(result)
            end 
        end
        disposeDisposable(disposable)
        return disposable 
    end
    return nil
end 
