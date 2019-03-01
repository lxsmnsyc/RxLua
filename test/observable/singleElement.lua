local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onComplete()
end)
:singleElement()
:subscribe{
    onSuccess = function (x)
        print("Success!", x)
    end,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}


Observable.create(function (e)
    e:onComplete()
end)
:singleElement()
:subscribe{
    onSuccess = print,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("hello")
    e:onComplete()
end)
:singleElement()
:subscribe{
    onSuccess = function (x)
        print("Success!", x)
    end,
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}