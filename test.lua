local extends = require "RxLua.src.interface.extends"

local A = {}
local A_MT = {__index = A}

function A.new(name)
	return setmetatable({_name = name}, A_MT)
end 

function A:speak()
	print(self._name)
end

local testA = A.new("Alexis")
testA:speak()

local B = extends(A)
local B_MT = {__index = B}

function B.new(name)
	return setmetatable({_name = name}, B_MT)
end 

function B:speak()
	print("Woah", self._name)
end

local C = setmetatable({}, {
	__call = B.new,
	__index = B
})

local testB = C("Munsayac")
testB:speak()