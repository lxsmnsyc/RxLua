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


local isDisposed = require "RxLua.src.disposable.interface.isDisposed"
local dispose = require "RxLua.src.disposable.interface.dispose"

local badArgument = require "RxLua.src.asserts.badArgument"

--[[
	Returns a Completable that first runs this 
	Completable and then the other completable.
]]
return function (source, next)
	local context = debug.getinfo(1).name
	badArgument(is(source), 1, context, "Completable")
	badArgument(is(next), 2, context, "Completable")

	
	return Completable(nil, function (observer)
		local actualSubscribe = observer.onSubscribe
		local actualError = observer.onError
		local actualComplete = observer.onComplete
		
		local upstream
		
		subscribe(source, CompletableObserver(_, {
			onSubscribe = function (d) 
				if(upstream) then 
					error("Protocol Violation: Disposable already set.")
				else 
					upstream = d
					actualSubscribe(d)
				end
			end,
			onError = function (t)
				actualError(t)
			end,
			onComplete = function ()
				local parent = upstream
				subscribe(next, CompletableObserver(_, {
					onSubscribe = function (d)
						if(parent ~= d) then 
							if(isDisposed(parent)) then 
								dispose(d)
							end 
							parent = d
						end 
					end,
					onComplete = function ()
						actualComplete()
					end,
					onError = function (t)
						actualError(t)
					end
				}))
			end,
		}))
	end)
end 