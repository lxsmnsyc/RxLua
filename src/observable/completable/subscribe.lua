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
local isAction = require "RxLua.src.functions.action.is"

local CallbackCompletableObserver = require "RxLua.src.observer.completable.callback.new"
local EmptyCompletableObserver = require "RxLua.src.observer.completable.empty.new"


local badArgument = require "RxLua.src.asserts.badArgument"

return function (observable, onComplete, onError)
	--[[
		Argument check
	]]
    badArgument(is(observable), 1, debug.getinfo(1).name, "Completable")
	--[[
		Core of the subscribe method
	]]
    local function subscribeCore(observer)
        observable._subscribeActual(observer)
    end 

    local observer
	--[[
		Check if the first argument is a valid observer
	]]
    if(isObserver(onComplete)) then 
		--[[
			Subscribe
		]]
        subscribeCore(onComplete)
        return
	--[[
		Otherwise, if the provided argument is a function or an Action,
		create a CallbackCompletableObserver
	]]
    elseif(type(onComplete) == "function" or isAction(onComplete)) then  
        observer = CallbackCompletableObserver(nil, onComplete, onError)
	--[[
		Create an EmptyCompletableObserver instead.
	]]
    else 
        observer = EmptyCompletableObserver()
    end 
	--[[
		Subscribe the created Observer
	]]
    subscribeCore(observer)
    return observer
end 
