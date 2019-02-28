local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onNext(1)
    e:onNext(2)
    e:onNext("alexis")
    e:onComplete()
end)
:filter(function (x)
    return type(x) == "string"
end)
:subscribe{
    onNext = print
}