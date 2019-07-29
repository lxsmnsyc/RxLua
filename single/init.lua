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

local SingleSource = require "RxLua.single.source"

local LambdaSingleObserver = require "RxLua.single.observer.lambda"

local WrapperSubscription = require "RxLua.subscription.wrapper"

local Single = extend(SingleSource)


function Single:pipe(...)
  -- get the transformers
  local transformers = {...}

  -- iterate the transformers
  for _, transformer in ipairs(transformers) do
    assert(type(transformer) == "function")
    self = transformer(self)
    assert(typeof(self, Single))
  end

  return self
end

function Single:subscribeWith(observer)
  self:subscribeActual(observer)
  return observer
end

function Single:subscribe(onSuccess, onError)
  return WrapperSubscription.new(self:subscribeWith(LambdaSingleObserver.new(onSuccess, onError)))
end

function Single:subscribeActual(observer)
end

return Single