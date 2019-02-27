local Rx = require "RxLua"

Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)
:doOnTerminate(function (x)
    print("Terminated!")
end)
:subscribe(print, print)


Rx.Single.create(function (e)
    e:onError("Oops!")
end)
:doOnTerminate(function (x)
    print("Terminated!")
end)
:subscribe(print, print)
