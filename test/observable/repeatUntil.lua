local Observable = require "RxLua.observable"

math.randomseed(os.time())

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onNext(1)
    e:onNext(2)
    e:onNext("alexis")
    e:onComplete()
end)
:repeatUntil(function ()
    return math.random(100) < 50
end)
:subscribe{
    onNext = function (x)
        print(x)
    end,
    onComplete = function ()
        print("completed")
    end,
}

