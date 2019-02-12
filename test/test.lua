local describe = require "RxLua.test"

describe("Example test", function ()
    describe("Fail add", function ()
        local a = a + 1
    end)
    describe("Fail abs", function ()
        math.abs(nil)
    end)
    describe("Pass sub", function ()
        local a = 0 
        a = a + 1
    end)
    describe("Pass abs", function ()
        math.abs(0)
    end)
end)