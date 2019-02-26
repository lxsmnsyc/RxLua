local Rx = require "RxLua"

Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)
:flatMapMaybe(function (x)
    print("Success: "..x)
    return Rx.Maybe.create(function (e)
        e:onSuccess("Received: "..x)
    end)
end)
:subscribe(print, print)