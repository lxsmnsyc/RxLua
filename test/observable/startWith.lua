local Observable = require "RxLua.observable"

local observable = Observable.just("World")
:startWith("Hello")

observable:subscribe{
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

observable:startWith{"Hello", "World", "Again"}
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

Observable.create(function (e)
    for i = 1, 5 do 
        e:onNext(i)
    end 
    e:onComplete()
end)
:startWith(observable)
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