local isErrorObserver = require "RxLua.is.observer.error"
local isFunction = require "RxLua.utils.function"

return function (observer)
  return isErrorObserver(observer)
    and isFunction(observer.onNext)
    and isFunction(observer.onComplete)
end