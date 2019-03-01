local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onComplete()
end)
:lastElementOrError("default")
:subscribe{
    onSuccess = print,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}