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
local extend = require "RxLua.utils.extend"
local typeof = require "RxLua.utils.typeof"
local create = require "RxLua.utils.create"

local Single = require "RxLua.single"
local SingleSource = require "RxLua.single.source"
local SingleObserver = require "RxLua.single.observer"

local SimpleSubscription = require "RxLua.subscription.simple"

local SingleJust = extend(Single)

function SingleJust:subscribeActual(observer)
  assert(typeof(observer, SingleObserver))
  local subscription = SimpleSubscription.new()
  observer:onSubscribe(subscription)
  if (subscription.alive) then
    observer:onSuccess(self.value)
  end
end

return function (value)
  assert(value ~= nil)

  local instance = create(SingleJust)
  instance.value = value

  return instance
end