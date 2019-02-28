local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("world")
    e:onNext("world")
    e:onComplete()
end)
:all(function (x)
    return x == "world"
end)
:subscribe{
    onSuccess = print,
    onError = print
}

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onComplete()
end)
:all(function (x)
    return x == "world"
end)
:subscribe{
    onSuccess = print,
    onError = print
}