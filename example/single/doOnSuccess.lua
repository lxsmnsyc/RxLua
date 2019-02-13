local Rx = require "RxLua"

Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)
:doOnSuccess(function (x)
    print("Success! "..x)
end)
:subscribe(print, print)
