local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onNext(1)
    e:onNext(2)
    e:onNext("alexis")
    e:onComplete()
end)
:repeatFor(5)
:subscribe{
    onNext = function (x)
        print(x)
    end,
    onComplete = function ()
        print("completed")
    end,
}

