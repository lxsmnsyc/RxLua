local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onError("Oopsie")
end)
:doOnNext(function (x)
    print("Next: ", x)
end)
:subscribe{
    onNext = print,
    onComplete = function ()
        print("Completed")
    end
}