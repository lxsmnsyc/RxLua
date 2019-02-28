local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onError("Oopsie")
end)
:doOnError(function (x)
    print("Terminated", x)
end)
:subscribe{
    onNext = print,
    onComplete = function ()
        print("Completed")
    end
}