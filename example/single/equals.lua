local Rx = require "RxLua"

local A = Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)
local B = Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)

A:equals(B):subscribe(print, print)

local C = Rx.Single.create(function (e)
    e:onSuccess("Other Hello")
end)

A:equals(C):subscribe(function (x)
    print(x and "Passed" or "Failed")
end, print)
