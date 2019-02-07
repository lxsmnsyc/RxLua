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

local is = require "RxLua.src.disposable.composite.is"

local isDisposable = require "RxLua.src.disposable.is"
local dispose

local badArgument = require "RxLua.src.asserts.badArgument"

return function (composite)
    dispose = dispose or require "RxLua.src.disposable.dispose"
    --[[
        Assert arguments
    ]]
    local context = debug.getinfo(1).name
    --[[
        Argument #1: CompositeDisposable
        Argument #2: Disposable
    ]]
    badArgument(is(composite), 1, context, "CompositeDisposable")
    badArgument(isDisposable(disposable), 2, context, "Disposable")

    --[[
        If the composite is already disposed, exit
    ]]
    if(composite._disposed) then 
        return
    end 
    --[[
        Check if there are Disposables
    ]]
    if(composite._size > 0) then 
        local list = composite._disposables
        --[[
            Dispose every Disposable
        ]]
        for k, disposable in ipairs(list) do 
            dispose(disposable)
        end 

        composite._disposables = {}
        composite._indeces = {}
        composite._size = 0
    end
end