local Observable = require "RxLua.observable"

local A = Observable.just("Hello World")

A:subscribe{
    onNext = function (x)
        print(x)
    end,
    onComplete = function ()
        print("Completed")
    end
}