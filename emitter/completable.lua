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

local function new(_, onComplete, onError)
    return setmetatable({
        _onError = onError,
        _onComplete = onComplete
    }, M)
end

local function emitOnError(self, t)
    if(t == nil) then 
        t = "Emitter onError received a nil value. Nil values are not allowed."
    end

    if(not isDisposed(self)) then 
        pcall(self._onError, t)
        dispose(self)
    else 
        HostError(t)
    end
end

local function emitOnComplete(self)
    if(not isDisposed(self)) then 
        pcall(self._onComplete)
        dispose(self)
    end
end

M.__call = new
M.__index = {
    onError = emitOnError,
    onComplete = emitOnComplete,
    dispose = dispose,
    isDisposed = isDisposed
}

return setmetatable({}, M)