local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onNext("alexis")
    e:onComplete()
end)
:map(function (x)
    return #x
end)
:subscribe{
    onNext = print
}