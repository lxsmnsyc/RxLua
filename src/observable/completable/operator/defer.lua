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

local produceAction = require "RxLua.src.functions.action.produce"
local run = require "RxLua.src.functions.action.run"

local badArgument = require "RxLua.src.asserts.badArgument"

local emptyError = require "RxLua.src.disposable.empty.error"


return function (action)
	action = produceAction(action)
	badArgument(action, 1, debug.getinfo(1).name, "Action or function")
	
	return Completable(nil, function (observer)
		local status, result = pcall(function ()
			return run(action)
		end)
		
		if(status) then 
			subscribe(result, observer)
		else 
			emptyError(observer, result)
		end
	end)
end