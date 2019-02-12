local Rx = require "RxLua"

local A = Rx.Class("A"){
    new = function (self, x)
        self.x = x
    end,

    printA = function (self)
        print("A: "..self.x)
    end
}

local B = Rx.Class("B"){
    new = function (self, x)
        self.x = x
    end,

    printB = function (self)
        print("B: "..self.x)
    end
}

local C = Rx.Class("C", A, B){
    new = function (self, x)
        self:super(x)
    end,
}

local C1 = C("Hello World")

C1:printA()
C1:printB()
print(C1:instanceof(A))
print(C1:instanceof(B))