--[[
    Reactive Extensions Single Emitter
	
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
local implement = require "RxLua.src.interface.implement"

local DisposableInterface = require "RxLua.src.disposable.interface.M"

local path = "RxLua.src.emitter.single"

local function load(name)
    return require(path.."."..name)
end 

local M = load("M")

local SingleEmitter = setmetatable({}, M)

SingleEmitter.is = load("is")

local isDisposed = load("isDisposed")
local dispose = load("dispose")

M.__call = load("new")
M.__index = {
    setDisposable = load("setDisposable"),
    isDisposed = isDisposed,
    dispose = dispose
}

implement(DisposableInterface, M, {
    isDisposed = isDisposed,
    dispose = dispose
})

return SingleEmitter