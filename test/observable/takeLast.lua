local Observable = require "RxLua.observable"


Observable.create(function (e)
    for i = 1, 10 do
        e:onNext(i)
    end
    e:onComplete()
end)
:takeLast(5)
:subscribe{
    onNext = print,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}