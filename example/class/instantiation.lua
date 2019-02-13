local Rx = require "RxLua"

local A = Rx.Class("A"){
    new = function (self, x)
        self.x = x
    end,
}

local A1 = A("Hello World")
print(A1.x)