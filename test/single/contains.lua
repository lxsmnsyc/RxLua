local Single = require "RxLua.single"

local A = Single.create(function (e) 
    e:onSuccess("hello") 
end)

A:contains("hello")
:subscribe{onSuccess = print}

A:contains("world")
:subscribe{onSuccess = print}