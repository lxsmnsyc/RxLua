local Rx = require "RxLua"

local A = Rx.Single.error(function (e)
    error("Oopsie!")
end)

A:subscribe(print, print)