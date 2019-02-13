local Rx = require "RxLua"

local A = Rx.Class("A"){

    new = function (self, x)
        self.x = x
    end,

    printX = function (self)
        print(self.x)
    end,

    printOther = function ()
        print("Hello World")
    end
}

local A1 = A("Hello")

A1:printX()

A1.printX(A1)

A1.printOther()