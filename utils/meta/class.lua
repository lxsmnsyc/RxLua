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

local badArgument = require "Rx.utils.badArgument"

local function is(class)
    return type(class) == "table" and class._class
end 

local function instanceof(object, class)
    --[[
        
    ]]
    if(type(object) == "table" and is(class)) then 
        if(getmetatable(object).__index == getmetatable(class).__index) then 
            return true 
        else
            local function findParent(parents, parent)
                for k,v in pairs(parents) do 
                    if(parent == v or findParent(v._parents, parent)) then 
                        return true 
                    end
                end 
                return false
            end

            return findParent(object._parents, class)
        end
    end 
    return false 
end 

return function (name, ...)
    local receivedName = type(name)
    badArgument(receivedName == "string", 1, "string", receivedName)
    --[[
        The class
    ]]
    local C = {}
    --[[
        The metatable
    ]]
    local M = {__index = C}
    --[[
        Check for parents
    ]]
    local parents = {...}
    local count = #parents 
    if(count > 0) then 
        --[[
            Validate parents
        ]]
        for k, v in ipairs(parents) do 
            badArgument(is(v), k + 1, "Class")
        end 
        --[[
            If there is only one parent, set it for indexing
        ]]
        if(count == 1) then 
            C = setmetatable(C, {__index = parents[1]})
        else 
            --[[
                Use a lookup instead.
            ]]
            C = setmetatable(C, {
                __index = function (t, k)
                    for _, parent in ipairs(parents) do 
                        for name, field in pairs(parent) do 
                            if(name == k) then 
                                return field 
                            end
                        end 
                    end
                end 
            })
        end 
    end 
    --[[
        Instanciator
    ]]
    local function new()
        return setmetatable({}, M)
    end 

    local function caller(t)
        return new()
    end 
    --[[
        To only allow the closure to be called once
    ]]
    local defineOnce = true 
    return function (methods)
        --[[
            Check if the closure has yet to be called
        ]]
        if(defineOnce) then 
            --[[
                Prevent from being called again
            ]]
            defineOnce = false 
            --[[
                check if there are any methods
            ]]
            if(type(methods) == "table") then
                --[[
                    Iterate every method
                ]]
                for name, field in pairs(methods) do 
                    --[[
                        Check if the method is a "new" method
                    ]]
                    if(name == "new") then 
                        --[[
                            Set the new inner constructor
                        ]]
                        caller = function (t,...)
                            local self = new()
                            field(self, ...)
                            return self
                        end 
                    else
                        C[name] = field
                    end
                end
            end

            --[[
                Return the proxy table
            ]]
            C._parents = parents
            C._className = name
            C.instanceof = instanceof
            return setmetatable({
                _class = true
            }, {
                __call = caller,
                __index = C,
            })
        end 
    end 
end 