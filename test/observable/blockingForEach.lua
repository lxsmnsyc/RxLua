local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onComplete()
end):blockingForEach(print)