local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onComplete()
end)
:doAfterTerminate(function ()
    print("Terminated")
end)
:subscribe{
    onNext = print,
    onComplete = function ()
        print("Completed")
    end
}

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onError("Oopsie!")
end)
:doAfterTerminate(function ()
    print("Terminated")
end)
:subscribe{
    onNext = print,
    onError = print
}