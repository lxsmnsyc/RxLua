local Rx = require "RxLua"

Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)
:flatMapCompletable(function (x)
    print("Success: "..x)
    return Rx.Completable.create(function (e)
        e:onComplete()
    end)
end)
:subscribe(function ()
    print("completed")
end, print)