local Observer = require "RxLua.src.observer.is"
local DefaultObserver = require "RxLua.src.observer.default.is"
local DisposableObserver = require "RxLua.src.observer.disposable.is"

return function (observer)
    return Observer(observer)
        or DefaultObserver(observer)
        or DisposableObserver(observer)
end 