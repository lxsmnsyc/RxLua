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

local class = require "Rx.utils.meta.class"

local Disposable = require "Rx.disposable"
local CompletableObserver = require "Rx.observer"

local Action = require "Rx.functions.action"
local Consumer = require "Rx.functions.consumer"

local ProtocolViolation = require "Rx.utils.protocolViolation"
local BadArgument = require "Rx.utils.badArgument"

return class ("EmptyCompletableObserver", Disposable, CompletableObserver){
    onSubscribe = function (self, disposable) 
        local upstream = self.upstream 
        if(upstream) then 
            disposable:dispose()
            if(upstream:isDisposed()) then 
                ProtocolViolation("Double subscription on observer; Disposable already set!")
            end 
            return  
        end 
        self.upstream = disposable
    end,
    
    onComplete = function (self)
        self.upstream:dispose()
    end,
    
    onError = function (self, t)
        self.upstream:dispose()
    end,


    dispose = function (self)
        self.upstream:dispose()
    end,

    isDisposed = function (self)
        return self.upstream:isDisposed()
    end 
}