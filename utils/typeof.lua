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

local function typeof(instance, parent)
  -- make sure that the instance and the parent
  -- are tables
  if (type(instance) ~= "table") then
    return false
  end
  if (type(parent) ~= "table") then
    return false
  end
  -- get the metatable
  local mt = getmetatable(instance)

  if mt then
    -- check if the metatable is that of the parent
    if (mt == parent) then
      return true
    end

    -- get the __parents
    local parents = mt.__parents

    -- check if there are any parents
    if (parents == nil) then
      return typeof(mt, parent)
    end

    -- check if one of the parents is the given parent
    for _, p in ipairs(parents) do
      -- compare parent
      if (p == parent) then
        return true
      -- otherwise check if the iterated parent
      -- is a descendant
      elseif (typeof(p, parent)) then
        return true
      end
    end
  end

  -- check failed
  return false
end

return typeof