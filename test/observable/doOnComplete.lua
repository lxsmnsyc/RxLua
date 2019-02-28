local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onComplete()
end)
:doOnComplete(function ()
    print("Terminated")
end)
:subscribe{
    onNext = print,
    onComplete = function ()
        print("Completed")
    end
}