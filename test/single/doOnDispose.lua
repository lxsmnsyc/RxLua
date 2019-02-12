local Rx = require "RxLua"

local disposable = Rx.Single.create(function (e)
end)
:doOnDispose(function (x)
    print("Disposed!")
end)
:subscribe(print, print)

disposable:dispose()