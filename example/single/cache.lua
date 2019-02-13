local Rx = require "RxLua"

local A = Rx.Single.create(function (e)
    e:onSuccess("Hello World")
end)

local cached = A:cache()

cached:subscribe(print, print)
cached:subscribe(print, print)
cached:subscribe(print, print)
cached:subscribe(print, print)