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

local M = require "RxLua.src.observer.safe.M"

local isObserver = require "RxLua.src.observer.interface.is"

local dispose = require "RxLua.src.disposable.interface.dispose"

local EMPTY = require "RxLua.src.disposable.empty.instance"

local badArgument = require "RxLua.src.asserts.badArgument"
return function (_, observer)
    local this = {
        _disposable = nil,
        _className = "SafeObserver"
    }

    local onSubscribe = observer.onSubscribe
    local onNext = observer.onNext 
    local onError = observer.onError 
    local onComplete = observer.onComplete

    local done = false

    this.onSubscribe = function (d) 
        if(d == nil) then 
            error("Protocol Violation: d is nil")
        end 

        if(current == nil) then 
            this._disposable = d

            local status, result = pcall(function ()
                onSubscribe(d)
            end)

            if(not status) then 
                done = true 
                dispose(d)
                error(result)
            end
        else 
            dispose(d)
            error("Protocol Violation: Disposable already set.")
        end
    end

    this.onNext = function (x)
        if(done) then 
            return 
        end 

        if(this._disposable == nil) then 
            done = true 

            local ex = "Protocol Violation: Subscription not set."

            local status, result = pcall(function ()
                onSubscribe(EMPTY)
            end)

            if(not status) then 
                error(ex + "\n" + result)
                return
            end 

            status, result = pcall(function ()
                onError(ex)
            end)

            if(not status) then 
                error(ex + "\n" + result)
                return 
            end
        end 

        
    end 
    return setmetatable(this, M)
end 