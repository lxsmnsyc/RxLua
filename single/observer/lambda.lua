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

local LambdaSingleObserver = extend(SingleObserver, Subscription)

function LambdaSingleObserver.new(onSuccess, onError)
  local instance = create(LambdaSingleObserver)
  instance.onSuccessCallback = onSuccess
  instance.onErrorCallback = onError
  instance.alive = true
  instance.subscribed = false
  return instance
end

function LambdaSingleObserver:onSubscribe(subscription)
  assert(typeof(subscription, Subscription))

  if (self.alive and not self.subscribed) then
    self.subscribed = true
    self.subscription = subscription
  else
    subscription:cancel()
  end
end

function LambdaSingleObserver:onSuccess(value)
  assert(value ~= nil)
  if (self.alive and self.subscribed) then
    local onSuccessCallback = self.onSuccessCallback

    if (type(onSuccessCallback) == "function") then
      onSuccessCallback(value)
    end

    self:cancel()
  end
end

function LambdaSingleObserver:onError(err)
  assert(err ~= nil)
  if (self.alive and self.subscribed) then
    local onErrorCallback = self.onErrorCallback

    if (type(onErrorCallback) == "function") then
      onErrorCallback(err)
    end

    self:cancel()
  else
    error(err)
  end
end

function LambdaSingleObserver:cancel()
  if (self.alive) then
    self.alive = false
    self.subscription:cancel()
  end
end

return LambdaSingleObserver