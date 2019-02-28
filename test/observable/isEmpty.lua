local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onComplete()
end)
:isEmpty()
:subscribe{
    onSuccess = print,
    onError = print
}

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onComplete()
end)
:isEmpty()
:subscribe{
    onSuccess = print,
    onError = print
}