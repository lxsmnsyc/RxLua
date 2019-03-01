local Observable = require "RxLua.observable"


Observable.create(function (e)
    e:onComplete()
end)
:singleElementOrError("no items!")
:subscribe{
    onComplete = function ()
        print("Completed")
    end,
    onError = print
}