local Rx = require "RxLua"

Rx.Single.fromCallable(function ()
    return math.random()
end)
:subscribe(print, error)