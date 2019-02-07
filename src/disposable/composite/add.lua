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
local dispose = require "RxLua.src.disposable.dispose"

local isDisposable = require "RxLua.src.global.disposable.is"

local badArgument = require "RxLua.src.asserts.badArgument"

return function (composite, ...)
    --[[
        Check for initial valid argument
    ]]
    local context = debug.getinfo(1).name
    badArgument(is(composite), 1, context, "CompositeDisposable")
    --[[
        Get the rest of the arguments assuming that 
        all of it are of Disposable instance.
    ]]
    local disposables = {...}

    local list = composite._disposables
    local indeces = composite._indeces 
    local count = composite._size

    local disposed = composite._disposed

    --[[
        Iterate through the argument Disposables
    ]]
    for k, disposable in ipairs(disposables) do 
        --[[
            Assert: argument is a Disposable instance.
        ]]
        badArgument(isDisposable(disposable), k + 1, context, "Disposable")

        --[[
            If the composite is disposed, dispose the disposable that is
            to be added, otherwise, add it to the list of disposables.
        ]]
        if(disposed) then 
            count = count + 1

            list[count] = disposable
            indeces[disposable] = count
        else 
            dispose(disposable)
        end
    end
    --[[
        Save the new size
    ]]
    composite._size = count
end 