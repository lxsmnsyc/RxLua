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

local BadArgument = require "Rx.utils.badArgument"

return function (self, ...)
    local ds = {...}
    if(not self.disposed) then 
        local resources = self.resources 
        local indeces = self.indeces
        local size = self.size 
        for _, disposable in ipairs(ds) do 
            local status, result = pcall(function ()
                return disposable:instanceof(Disposable)
            end)
            BadArgument(status and result, _ + 1, "Disposable")

            size = size + 1
            resources[size] = disposable
            indeces[disposable] = size
        end 
        self.size = size 

        return true 
    end 

    for _, disposable in ipairs(ds) do 
        local status, result = pcall(function ()
            disposable:dispose()
        end)
        BadArgument(status, _ + 1, "Disposable")
    end 

    return false
end