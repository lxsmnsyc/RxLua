local M = require "RxLua.src.observer.M"

return function (x)
    return type(x) == "table" and getmetatable(x) == M
end