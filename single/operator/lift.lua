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

local try = require "RxLua.utils.try"

local Single = require "RxLua.single"
local SingleSource = require "RxLua.single.source"
local SingleObserver = require "RxLua.single.observer"

local SimpleSubscription = require "RxLua.subscription.simple"

local SingleLift = extend(Single)

function SingleLift:subscribeActual(observer)
  assert(typeof(observer, SingleObserver))

  local result
  try(
    function ()
      result = self.operator(observer)

      assert(typeof(result, SingleObserver))
    end,
    function (e)
      local subscription = SimpleSubscription.new()
      observer:onSubscribe(subscription)
      if (subscription.alive) then
        observer:onError(e)
      end
    end
  )

  if (result) then
    self.source:subscribe(result)
  end
end

return function (operator)
  assert(type(operator) == "function")
  return function (source)
    assert(typeof(source, SingleSource))
    
    local instance = create(SingleLift)
    instance.source = source
    instance.operator = operator
  
    return instance
  end
end