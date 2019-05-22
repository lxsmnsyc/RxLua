local isTable = require "RxLua.utils.isTable"
local isFunction = require "RxLua.utils.isFunction"

return function (observer)
  return isTable(observer)
    and isFunction(observer.onSubscribe)
end