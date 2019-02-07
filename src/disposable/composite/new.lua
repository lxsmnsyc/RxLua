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
local M = require "RxLua.src.disposable.composite.M"

local isDisposable = require "RxLua.src.disposable.is"

local badArgument = require "RxLua.src.asserts.badArgument"

return function (_, disposables)
    local context = debug.getinfo(1).name 
    
    local composite = {
        _className = "CompositeDisposable",
        _disposed = false
    }

    local count = 0
    local indeces = {}
    local list = {}
    if(type(disposables) == "table") then 
        for k, disposable in ipairs(disposables) do 
            --[[
                Assert: argument is a Disposable instance.
            ]]
            badArgument(isDisposable(disposable), k + 1, context, "Disposable")
            count = count + 1

            list[count] = disposable
            indeces[disposable] = count
        end
    end 

    composite._disposables = list 
    composite._indeces = indeces
    composite._size = count 

    return setmetatable(composite, M)
end 