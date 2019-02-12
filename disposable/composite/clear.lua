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

local CompositeException = require "RxLua.utils.compositeException"
local function dispose(set)
    if(set == nil) then 
        return 
    end 

    local errors, errc = {}, 0

    for _, o in ipairs(set) do 
        local status, result = pcall(function ()
            return o:instanceof(Disposable)
        end)
        if(status and result) then 
            local status, result = pcall(function ()
                o:dispose()
            end)

            if(not status) then 
                errc = errc + 1
                errors[errc] = result
            end
        end 
    end 

    if(errc > 0) then 
        CompositeException(errors)
    end
end 

return function (self)
    if(self._disposed) then 
        return 
    end 

    dispose(self._resources)

    self._resources = {}
    self._size = 0
    self._indeces = {}
end