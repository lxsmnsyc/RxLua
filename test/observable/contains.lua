local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("hello")
    e:onComplete()
end)
:contains("world")
:subscribe{
    onSuccess = print,
    onError = print
}

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onComplete()
end)
:contains("world")
:subscribe{
    onSuccess = print,
    onError = print
}