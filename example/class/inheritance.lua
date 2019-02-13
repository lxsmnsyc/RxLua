local Rx = require "RxLua"

local A = Rx.Class("A"){

    new = function (self, x)
        print("wtf")
        self.x = x
    end,

    printX = function (self)
        print(self.x)
    end
}

local B = Rx.Class("B", A){
    new = function (self, x)
        self:super(x)
    end
}

local B1 = B("Hello")

B1:printX()