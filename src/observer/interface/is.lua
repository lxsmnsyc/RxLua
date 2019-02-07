local Observer = require "RxLua.src.observer.is"
local DefaultObserver = require "RxLua.src.observer.default.is"
local DisposableObserver = require "RxLua.src.observer.disposable.is"
local LambdaObserver = require "RxLua.src.observer.lambda"

return function (observer)
    return Observer(observer)
        or DefaultObserver(observer)
        or DisposableObserver(observer)
        or LambdaObserver(observer)
end 