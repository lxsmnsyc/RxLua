local isErrorObserver = require "RxLua.is.observer.error"
local isFunction = require "RxLua.is.function"

return function (observer)
  return isErrorObserver(observer)
    and isFunction(observer.onComplete)
end