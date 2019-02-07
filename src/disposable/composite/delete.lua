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
local isDisposed = require "RxLua.src.disposable.composite.isDisposed"

local isDisposable = require "RxLua.src.disposable.is"

return function (composite, disposable)
    local fname = debug.getinfo(1).name
    assert(is(composite), "bad argument #1 to '"..fname.."' (CompositeDisposable expected).")
    assert(isDisposable(disposable), "bad argument #2 to '"..fname.."'")

    if(isDisposed(composite)) then 
        return false 
    end 
    
    local count = composite._size
    if(count > 0) then 
        local list = composite._disposables
        local indeces = composite._indeces 

        local index = indeces[disposable]

        if(index) then 
            local lastDisposable = list[count]
            list[index] = lastDisposable
            indeces[lastDisposable] = index 
            count = count - 1

            return true 
        end 
    end 
    return false
end