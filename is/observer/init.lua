local isTable = require "RxLua.is.isTable"
local isFunction = require "RxLua.is.isFunction"

return function (observer)
  return isTable(observer)
    and isFunction(observer.onSubscribe)
end