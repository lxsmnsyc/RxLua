local Observable = require "RxLua.observable"

print(Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onComplete()
end):blockingLast())