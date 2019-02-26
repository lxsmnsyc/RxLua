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
local class = require "RxLua.utils.meta.class"

local SingleSource = require "RxLua.source.single"

local Single 
local SingleFromUnsafeSource

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleFromUnsafeSource = class("SingleFromUnsafeSource", Single){
            new = function (self, source)
                self._source = source 
            end, 
            subscribeActual = function (self, observer)
                self._source:subscribe(observer)
            end, 
        }
    end 
end


local BadArgument = require "RxLua.utils.badArgument"

return function (source)
    BadArgument(SingleSource.instanceof(source, SingleSource), 1, "SingleSource")
    asyncLoad()
    return SingleFromUnsafeSource(source)
end