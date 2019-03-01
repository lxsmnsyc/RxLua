local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onComplete()
end)
:lastElementOrDefault("default")
:subscribe{
    onSuccess = print,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}