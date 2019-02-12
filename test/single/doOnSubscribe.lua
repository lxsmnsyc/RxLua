local Rx = require "RxLua"

Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)
:doOnSubscribe(function (d)
    print("Subscribed! ", d, d._className, d:instanceof(Rx.Disposable))
end)
:subscribe(print, print)
