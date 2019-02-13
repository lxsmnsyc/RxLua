local Rx = require "RxLua"

Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)
:doFinally(function (x)
    print("Terminated!")
end)
:subscribe(print, print)

Rx.Single.create(function (e)
    e:onError("Oops!")
end)
:doFinally(function (x)
    print("Terminated!")
end)
:subscribe(print, print)

local disposable = Rx.Single.create(function (e)
end)
:doFinally(function (x)
    print("Disposed!")
end)
:subscribe(print, print)

disposable:dispose()