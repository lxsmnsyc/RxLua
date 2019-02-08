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
local is = require "RxLua.src.observer.single.biconsumer.is"  
local badArgument = require "RxLua.src.asserts.badArgument"

local isDisposable
local isDisposed

local notLoaded = true
local function asyncLoad()
    if(notLoaded) then
        isDisposable = isDisposable or require "RxLua.src.disposable.interface.is"
        isDisposed = isDisposed or require "RxLua.src.disposable.interface.isDisposed"
        notLoaded = false 
    end
end

return function (observer)
    badArgument(is(observer), 1, debug.getinfo(1).name, "BiConsumerSingleObserver")
    asyncLoad()

    local disposable = observer._disposable

    if(isDisposed(disposable)) then 
        return false
    end

    return dispose(disposable)
end 