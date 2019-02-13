local Rx = require "RxLua"

local A = Rx.Single.create(function (emitter)
    emitter:onSuccess("Hello")
end)
local B = Rx.Single.create(function (emitter)
    emitter:onError("World")
end)

Rx.Single.amb({A, B}):subscribe(print, print)