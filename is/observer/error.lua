local isObserver = require "RxLua.is.observer"
local isFunction = require "RxLua.utils.function"

return function (observer)
  return isObserver(observer)
    and isFunction(observer.onError)
end