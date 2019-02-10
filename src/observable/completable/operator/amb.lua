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
local Completable = require "RxLua.src.observable.completable.new"
local subscribe = require "RxLua.src.observable.completable.subscribe"
local is = require "RxLua.src.observable.completable.is" 

local CompletableObserver = require "RxLua.src.observer.completable.new"

local CompositeDisposable = require "RxLua.src.disposable.composite.new"
local isCompositeDisposed = require "RxLua.src.disposable.composite.isDisposed"
local compositeAdd = require "RxLua.src.disposable.composite.add"
local compositeDelete = require "RxLua.src.disposable.composite.delete"
local compositeDispose = require "RxLua.src.disposable.composite.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

--[[
	Returns a Completable which terminates as soon 
	as one of the source Completables terminates 
	(normally or with an error) and disposes all 
	other Completables.
]]
return function (...)
	--[[
		Get the observables
	]]
	local observables = {...}
	--[[
		Check if all are completables
	]]
	for k, v in ipairs(observables) do 
		badArgument(is(v), k, context, "Completable")
		end
	
	local count = #observables > 0
	

	return Completable(nil, function (observer)
		local actualSubscribe = observer.onSubscribe
		local actualError = observer.onError
		local actualComplete = observer.onComplete
		--[[
			Create a CompositeDisposable
		]]
		local set = CompositeDisposable()
		--[[
			Holds the state of listening
		]]
		local once = true
		--[[
			Pass the set as the Disposable for the observer
		]]
		actualSubscribe(set)
		--[[
			Check if there are any competing Completables
		]]
		if(count) then
			--[[
				Iterate each observable
			]]
			for k, v in ipairs(observables) do 
				--[[
					only continue if the set is not yet disposed.
				]]
				if(isCompositeDisposed(set)) then 
					return 
				end
				--[[
					Holds the upstream disposable
				]]
				local upstream
				--[[
					Subscribe to the Completable
				]]
				subscribe(v, CompletableObserver(_, {
					--[[
						Add the upstream to the composite
					]]
					onSubscribe = function (d)
						upstream = d 
						compositeAdd(set, d)
					end,
					onComplete = function ()
						--[[
							Send signal if the state of once is true 
						]]
						if(once) then 
							--[[
								Toggle the state 
							]]
							once = false
							--[[
								Delete the upstream from the set 
							]]
							compositeDelete(set, upstream)
							--[[
								Dispose the set 
							]]
							compositeDispose(set)
							--[[
								Send the signal
							]]
							actualComplete()
						end 
					end,
					onError = function (t)
						--[[
							Send signal if the state of once is true 
						]]
						if(once) then 
							--[[
								Toggle the state 
							]]
							once = false
							--[[
								Delete the upstream from the set 
							]]
							compositeDelete(set, upstream)
							--[[
								Dispose the set 
							]]
							compositeDispose(set)
							--[[
								Send the signal
							]]
							actualError(t)
						else 
							error(t)
						end 
					end,
				}))
			end 
		else 
			--[[
				There are no observables, send a complete signal
			]]
			actualComplete()
		end 
	end)
end 