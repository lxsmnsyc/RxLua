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
local Disposable = require "Rx.disposable"

local DISPOSED = require "Rx.disposable.helper.disposed"
local FIELD = require "Rx.disposable.helper.FIELD"

local BadArgument = require "Rx.utils.badArgument"

local getAndSet = require "Rx.disposable.helper.getAndSet"

return function (field)
    BadArgument(Disposable.instanceof(field, Disposable), 1, "Disposable")
    local current = FIELD[field]

    if(current ~= DISPOSED) then 
        current = getAndSet(field, DISPOSED)
        if(current ~= DISPOSED) then 
            if(current) then 
                current:dispose()
            end 
            return true 
        end
    end
    return false 
end