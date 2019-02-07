
local is = require "RxLua.src.disposable.is"

local badArgument = require "RxLua.src.asserts.badArgument"

return function (disposable)
    badArgument(is(disposable))
    local cleanup = disposable.cleanup
    disposable._disposed = true 

    if(type(cleanup) == "function") then 
        disposable.cleanup()

        disposable.cleanup = nil
    end

    return true 
end