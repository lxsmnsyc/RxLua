local Rx = require "RxLua"

Rx.Single.create(function (e)
    e:onError("Oh no")
end)
:doOnError(function (x)
    print("Oops!")
    print(x)
end)
:subscribe(print)