local M = require "RxLua.src.onSubscribe.observable.M"

return function (x)
    return type(x) == "table" and getmetatable(x) == M
end