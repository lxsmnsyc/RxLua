local Observable = require "RxLua.observable"

local disposable = Observable.empty()
:switchIfEmpty(Observable.just("Hello World"))
:subscribe{
    onNext = function (x)
        print("Next: ", x)
    end,
    onError = function (x)
        print("Error:", x)
    end,
    onComplete = function ()
        print("Completed")
    end,
}
print(disposable:isDisposed())