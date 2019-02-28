local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onComplete()
end)
:firstOrDefault("no items")
:subscribe{
    onSuccess = print,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}