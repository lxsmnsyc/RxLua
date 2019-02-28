local Observable = require "RxLua.observable"

Observable.create(function (e)
end)
:doOnSubscribe(
    function (d)
        print("Subscribed!", d)
    end
)
:subscribe({})