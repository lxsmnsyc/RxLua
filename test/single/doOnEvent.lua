local Rx = require "RxLua"

Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)
:doOnEvent(function (x, t)
    print("Success! "..x)
end)
:subscribe(print, print)

Rx.Single.create(function (e)
    e:onError("Oops!")
end)
:doOnEvent(function (x, t)
    print("Terminated! "..t)
end)
:subscribe(print, print)
