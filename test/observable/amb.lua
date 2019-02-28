local Observable = require "RxLua.observable"

local A = Observable.create(function (e)
    e:onNext("hello")
    e:onNext("hello")
    e:onComplete()
end)

local B = Observable.create(function (e)
    e:onNext("world")
    e:onNext("world")
    e:onComplete()
end)

Observable.amb({B, A}):subscribe{onNext = print}