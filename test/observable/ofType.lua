local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onNext(1)
    e:onNext(2)
    e:onNext("alexis")
    e:onComplete()
end)
:ofType("number")
:subscribe{
    onNext = print
}