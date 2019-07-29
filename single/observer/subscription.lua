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

local SubscriptionSingleObserver = extend(SingleObserver, Subscription)

function SubscriptionSingleObserver.new(observer)
  local instance = create(SubscriptionSingleObserver)
  instance.observer = observer
  instance.alive = false
  return instance
end

function SubscriptionSingleObserver:onSubscribe(subscription)
  assert(typeof(subscription, Subscription))
  if (self.alive) then
    self.subscription = subscription
    self.observer:onSubscribe(self)
  else
    subscription:cancel()
  end
end

function SubscriptionSingleObserver:onSuccess(value)
  assert(value ~= nil)
  if (self.alive) then
    self.observer:onSuccess(value)
    self:cancel()
  end
end

function SubscriptionSingleObserver:onError(err)
  assert(err ~= nil)
  if (self.alive) then
    self.observer:onError(err)
    self:cancel()
  else
    error(err)
  end
end

function SubOnceSingleObserver:cancel()
  if (self.alive) then
    self.alive = false
    self.subscription:cancel()
  end
end

return SubscriptionSingleObserver