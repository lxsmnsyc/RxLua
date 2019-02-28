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
--]] 
local isDisposed = require "RxLua.disposable.isDisposed"
local dispose = require "RxLua.disposable.dispose"

local HostError = require "RxLua.utils.hostError"

local M = {}

local function new(_, onSuccess, onError)
    return setmetatable({
        _onSuccess = onSuccess,
        _onError = onError
    }, M)
end

local function emitOnError(self, t)
    if(t == nil) then 
        t = "Emitter onError received a nil value. Nil values are not allowed."
    end

    if(not isDisposed(self)) then 
        local try, catch = pcall(self._onError, t)
        dispose(self)
    else 
        HostError(t)
    end
end

local function emitOnSuccess(self, x)
    if(not isDisposed(self)) then 
        local try, catch = pcall(function ()
            if(x == nil) then 
                pcall(self._onError, "Emitter onSuccess received a nil value. Nil values are not allowed.")
            else 
                pcall(self._onSuccess, x)
            end
        end)
        dispose(self)
    end
end

M.__call = new
M.__index = {
    onError = emitOnError,
    onSuccess = emitOnSuccess,
    dispose = dispose,
    isDisposed = isDisposed
}

return setmetatable({}, M)