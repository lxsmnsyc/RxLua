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

local SingleSource = require "RxLua.source.single"
local Single 
local SingleDefer 

local notLoaded = true 
local function asyncLoad()
    if(notLoaded) then
        notLoaded = false 
        Single = require "RxLua.single"

        SingleDefer = class("SingleDefer", Single){
            new = function (self, callable)
                self._callable = callable
            end, 

            subscribeActual = function (self, observer)
                local try, catch = pcall(function ()
                    return self._callable()
                end)

                if(try) then 
                    if(SingleSource.instanceof(catch, SingleSource)) then 
                        catch:subscribe(observer)
                    else 
                        EmptyDisposable.error(observer, "The defer function did not return a SingleSource.")
                    end 
                else 
                    error(catch)
                    EmptyDisposable.error(observer, catch)
                end 
            end
        }
    end 
end

local BadArgument = require "RxLua.utils.badArgument"

return function (callable)
    BadArgument(type(callable) == "function", 1, "function", type(callable))
    asyncLoad()
    return SingleDefer(callable)
end 