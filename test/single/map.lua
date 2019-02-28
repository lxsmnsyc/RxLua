local Single = require "RxLua.single"

local A = Single.create(function (e) e:onSuccess("hello") end)
local B = A:map(function (e) return "Received: "..e end)

B:subscribe{onSuccess = print}