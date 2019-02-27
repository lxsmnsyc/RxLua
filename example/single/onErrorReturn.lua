local Rx = require "RxLua"

Rx.Single.error(function ()
    error("Oopsie!")
end)
:onErrorReturn(function (e)
    return "Received Error: "..e
end)
:subscribe(print)