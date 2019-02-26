local Rx = require "RxLua"

Rx.Single.just("Hello World")
:map(function (x)
    return "Received: "..tostring(x)
end)
:subscribe(print, error)