local Observable = require "RxLua.observable"

print(Observable.create(function (e)
    e:onNext("hello")
    e:onComplete()
end):blockingFirst())