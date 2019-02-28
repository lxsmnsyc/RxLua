local Observable = require "RxLua.observable"

Observable.create(function (e)
end)
:doOnLifecycle(
    function (d)
        print("Subscribed!")
    end,
    function ()
        print("Disposed")
    end
)
:subscribe({}):dispose()