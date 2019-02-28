local Observable = require "RxLua.observable"

for k, v in pairs(Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onComplete()
end):blockingIterable()) do 
    print(k, v)
end