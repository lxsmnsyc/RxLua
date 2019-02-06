local Rx = require "RxLua"

Rx.Single(function (emitter)
    emitter.success(123)
end):filter(function (x)
    return false
end):subscribe(Rx.MaybeObserver{
    onSuccess = print,
    onComplete = function ()
        print("That's okay.")
    end,
    onError = print
})