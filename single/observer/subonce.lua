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

local SingleObserver = require "RxLua.single.observer"

local Subscription = require "RxLua.subscription"

local SubOnceSingleObserver = extend(SingleObserver)

function SubOnceSingleObserver.new(observer)
  local instance = create(SubOnceSingleObserver)
  instance.observer = observer
  instance.subscribed = false
  return instance
end

function SubOnceSingleObserver:onSubscribe(subscription)
  assert(typeof(subscription, Subscription))
  if (self.subscribed) then
    subscription:cancel()
  else
    self.subscribed = true
    self.observer:onSubscribe(subscription)
  end
end

function SubOnceSingleObserver:onSuccess(value)
  assert(value ~= nil)
  if (self.subscribed) then
    self.observer:onSuccess(value)
  end
end

function SubOnceSingleObserver:onError(err)
  assert(err ~= nil)
  if (self.subscribed) then
    self.observer:onError(err)
  else
    error(err)
  end
end

return SubOnceSingleObserver