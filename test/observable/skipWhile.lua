local Observable = require "RxLua.observable"

local notifier = Observable.create(function () end)

Observable.create(function (e)
    for i = 1, 10 do
        e:onNext(i)
    end
    e:onComplete()
end)
:skipWhile(function (x)
    return x < 5
end)
:subscribe{
    onNext = print,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}