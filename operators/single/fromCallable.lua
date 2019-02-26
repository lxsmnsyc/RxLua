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

local EmptyDisposable = require "RxLua.disposable.empty"

local Single 
local SingleFromCallable

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"
        SingleFromCallable = class("SingleFromCallable", Single){
            new = function (self, source)
                self._handler = source 
            end, 
            subscribeActual = function (self, observer)
                local try, catch = pcall(self._handler)
                if(try) then 
                    EmptyDisposable.success(observer, catch)
                else
                    EmptyDisposable.error(observer, catch) 
                end
            end, 
        }
    end 
end


local BadArgument = require "RxLua.utils.badArgument"

local function isCallable(x)
    local xt = type(x)
    if(xt == "function") then 
        return true 
    elseif(xt == "table") then 
        local mt = getmetatable(x)
        if(mt) then 
            return type(mt.__call) == "function"
        end
    end
    return false 
end

return function (fn)
    BadArgument(isCallable(fn), 1, "function")
    asyncLoad()
    return SingleFromCallable(fn)
end