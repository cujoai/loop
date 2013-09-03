-- Project: LOOP Class Library
-- Release: 2.3 beta
-- Title  : Array Optimized for Insertion/Removal that Doesn't Garantee Order
-- Author : Renato Maia <maia@inf.puc-rio.br>
-- Notes  :
--   Can be used as a module that provides funcitons instead of methods.
--   Removal is replacing the element by the last one, which is then removed.


local _G = require "_G"
local tostring = _G.tostring

local table = require "table"
local concat = table.concat

local oo = require "loop.base"

local module = oo.class()

function module.add(self, value)
	self[#self + 1] = value
end

function module.remove(self, index)
	local size = #self
	if index == size then
		self[size] = nil
	elseif (index > 0) and (index < size) then
		self[index], self[size] = self[size], nil
	end
end

function module.__tostring(self)
	local result = { "{ " }
	for i = 1, #self do
		result[#result+1] = tostring(self[i])
		result[#result+1] = ", "
	end
	local last = #result
	result[last] = (last == 1) and "{}" or " }"
	return concat(result)
end

return module