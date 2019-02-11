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

local Disposable = require "RxLua.disposable"

local isDisposed = require "RxLua.disposable.helper.isDisposed"

local compareAndSet = require "RxLua.disposable.helper.compareAndSet"

local BadArgument = require "RxLua.utils.badArgument"
local ProtocolViolation = require "RxLua.utils.protocolViolation"

return function (field, disposable)
    BadArgument(Disposable.instanceof(field, Disposable), 1, "Disposable")
    BadArgument(Disposable.instanceof(disposable, Disposable) or disposable == nil, 2, "Disposable")

    if(not compareAndSet(field, nil, disposable)) then 
        disposable:dispose()
        if(not isDisposed(field)) then 
            ProtocolViolation("Disposable already set!")
        end
        return false 
    end
    return true 
end