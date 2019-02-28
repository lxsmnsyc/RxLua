local Observable = require "RxLua.observable"

Observable.create(function (e)
end)
:doOnDispose(function ()
    print("Disposed")
end)
:subscribe({}):dispose()