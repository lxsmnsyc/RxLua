local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onComplete()
end)
:doFinally(function ()
    print("Terminated")
end)
:subscribe{
    onComplete = function ()
        print("Completed")
    end
}

Observable.create(function (e)
    e:onError("Oopsie!")
end)
:doFinally(function ()
    print("Terminated")
end)
:subscribe{
    onError = print
}

Observable.create(function (e)
end)
:doFinally(function ()
    print("Disposed")
end)
:subscribe({}):dispose()