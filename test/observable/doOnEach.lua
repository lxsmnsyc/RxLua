local Observable = require "RxLua.observable"

Observable.create(function (e)
    e:onNext("hello")
    e:onNext("world")
    e:onComplete()
end)
:doOnEach(
    function (x)
        print("Next: "..x)
    end,
    function (x)
        print("Oopsie! "..x)
    end,
    function ()
        print("Completed")
    end
)
:subscribe{
    onNext = print,
    onError = print,
    onComplete = function ()
        print("Done")
    end
}