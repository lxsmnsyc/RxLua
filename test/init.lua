local class = require "RxLua.utils.meta.class"

local PASSED = "✓"
local FAILED = "✗"

local Describe = class("Describe"){
    new = function (self, description)
        self._description = description

        self._maxScore = 0
        self._score = 0
        self._reports = {}
    end,

    report = function (self, err)
        local reports = self._reports 
        reports[#reports + 1] = err
    end,

    pass = function (self)
        self._score = self._score + 1
    end,

    increment = function (self)
        self._maxScore = self._maxScore + 1
    end,

    passed = function (self)
        return self._score == self._maxScore
    end,

    evaluate = function (self)
        local score = self._score 
        local maxScore = self._maxScore 

        local passed = score == maxScore 

        local symbol 
        if(passed) then 
            symbol = PASSED 
        else 
            symbol = FAILED
        end 

        local header = symbol.." "..self._description..(maxScore > 1 and "["..(score - 1).."/"..(maxScore - 1).."]" or "")
        local reports = ""

        if(#self._reports > 0) then 
            reports = "\n\t"..table.concat(self._reports, "\n\t")
        end

        return header..reports
    end,

    print = function (self)
        print(self:evaluate())
    end 
}

local context

local function runTest(testField)
    local try, catch = pcall(testField)

    context:increment()
    if(try) then 
        context:pass()
    else 
        context:report("\t"..catch)
    end
end

local function describe(description, testField)
    local prevContext = context
    if(prevContext) then 
        prevContext:increment()
    end
    context = Describe(description)
    runTest(testField)
    if(prevContext) then 
        if(context:passed()) then 
            prevContext:pass()
        end 
        prevContext:report(context:evaluate())
    else
        context:print()
    end
    context = prevContext
end 

return describe