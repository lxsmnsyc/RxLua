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
local Maybe = require "RxLua.src.observable.maybe.new"

local MaybeOnSubscribe = require "RxLua.src.onSubscribe.maybe.new"
local isOnSubscribe = require "RxLua.src.onSubscribe.maybe.is"

local Emitter = require "RxLua.src.emitter.maybe.new"

local Disposable = require "RxLua.src.disposable.new"
local isDisposable = require "RxLua.src.disposable.interface.is"
local isDisposed = require "RxLua.src.disposable.interface.isDisposed"
local dispose = require "RxLua.src.disposable.interface.dispose"

local subscribe = require "RxLua.src.onSubscribe.maybe.subscribe"

local badArgument = require "RxLua.src.asserts.badArgument"

return function (subscriber)
	--[[
		Argument Check
	]]
    local isFunction = type(subscriber) == "function"
	--[[
		Only allow functions or CompletableOnSubscribe instances
	]]
    badArgument(isFunction or isOnSubscribe(subscriber), 1, debug.getinfo(1).name , "MaybeOnSubscribe or function")
	--[[
		Transform a function into a CompletableOnSubscribe
	]]
    if(isFunction) then 
        subscriber = MaybeOnSubscribe(nil, subscriber)
    end
	
	return Maybe(nil, function (observer)
		--[[
			Create an emitter
		]]
		local emitter = Emitter(nil, observer)
		--[[
			Create a Disposable state
		]]
		local state = Disposable()
		
		
		emitter.onSuccess = function(x)
			--[[
				Make sure that the state is not yet disposed
			]]
			if(not isDisposed(disposable)) then 
				--[[
					Attempt to send an onSuccess signal safely
				]]
				local status, result = pcall(function ()
					--[[
						Nil values are not allowed!
					]]
					if(x == nil) then 
						observer.onError("Protocol Violation: onSuccess called with nil: nil values are not allowed.")
					else
						observer.onSuccess(x)
					end
				end)
				--[[
					Dispose the state
				]]
				dispose(disposable)
			end
		end 

		emitter.onComplete = function()
			--[[
				Make sure that the state is not yet disposed
			]]
			if(not isDisposed(state)) then 
				--[[
					Try to call onComplete safely
				]]
				local status, result = pcall(function ()
					observer.onComplete()
				end)
				--[[
					Dispose the state
				]]
				dispose(state)
			end
		end 

		emitter.onError = function(t)
			--[[
				Nil values are not allowed!
			]]
			if(t == nil) then 
				t = "Protocol Violation: onError called with nil: nil values are not allowed."
			end
			--[[
				Make sure that the state is not yet disposed
			]]
			if(not isDisposed(state)) then 
				--[[
					Try to call onError safely
				]]
				local status, result = pcall(function ()
					observer.onError(t)
					end)
				--[[
					Dispose the state
				]]
				dispose(state)
			else 
				--[[
					Only throw an error if the state is disposed
				]]
				error(t)
			end
		end 

		emitter.setDisposable = function(d)
			--[[
				Make sure that the Disposable is not equal to the current state
			]]
			if(d ~= state) then
				--[[
					Dispose if the current state is disposed as 
					it is pointless to "undispose" an emitter.
				]]
				if(isDisposed(state)) then 
					dispose(d)
					return 
				else
					--[[
						Dispose the current state instead as it is not 
						interesting anymore.
					]]
					dispose(state)
					--[[
						Set the new state
					]]
					state = d
				end
			end
		end 

		emitter.isDisposed = function()
			return isDisposed(state)
		end 

		emitter.dispose = function()
			return dispose(state)
		end 

		--[[
			Pass the emitter as the Disposable to be received by 
			the onSubscribe function 
		]]
		local onSubscribe = observer.onSubscribe
		if(onSubscribe) then 
			onSubscribe(emitter)
		end 

		--[[
			Try to subscribe
		]]
		local status, result = pcall(function ()
			subscribe(subscriber, emitter)
		end)
		--[[
			Subscription failed, emit an error signal.
		]]
		if(not status) then 
			emitter.error(result)
		end 
	end)
end