
local isDisposable = require "RxLua.src.disposable"
local dispose = require "RxLua.src.disposable.dispose"

return function (observer)
    local disposable = observer._disposable

    return isDisposable(disposable) and disposable.isDisposed
end 