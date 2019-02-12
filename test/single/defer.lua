local Rx = require "RxLua"

local deferred = Rx.Single.defer(function ()
    return Rx.Single.create(function (emitter)
        emitter:onSuccess("Hello World")
    end)
end)

deferred:subscribe(
    function (x)
        print("A single has been born, emitted \""..x.."\"")
    end,
    print
)