local Observable = require "RxLua.observable"

local A = Observable.empty()

A:subscribe{
    onComplete = function ()
        print("Completed")
    end
}