local Observable = require "RxLua.observable"

local notifier = Observable.just("start!")

Observable.create(function (e)
    for i = 1, 10 do
        e:onNext(i)
    end
    e:onComplete()
end)
:takeUntil(notifier)
:subscribe{
    onNext = print,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}