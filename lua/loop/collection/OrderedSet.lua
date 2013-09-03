-- Project: LOOP Class Library
-- Release: 2.3 beta
-- Title  : Ordered Set Optimized for Insertions and Removals
-- Author : Renato Maia <maia@inf.puc-rio.br>
-- Notes  :
--   Can be used as a module that provides functions instead of methods.
--   Instance of this class should not store the name of methods as values.
--   To avoid the previous issue, use this class as a module on a simple table.
--   It cannot store itself, because this place is reserved.
--   Each element is stored as a key mapping to its successor.


local _G = require "_G"
local tostring = _G.tostring

local table = require "table"
local concat = table.concat

local oo = require "loop.base"

local CyclicSets = require "loop.collection.CyclicSets"
local addto = CyclicSets.add
local removeat = CyclicSets.removefrom

local module = oo.class()

module.contains = CyclicSets.contains

function module.empty(self)
	return self[self] == nil
end

function module.first(self)
	return self[ self[self] ]
end

function module.last(self)
	return self[self]
end

function module.successor(self, item)
	local last = self[self]
	if item ~= last then
		if item == nil then item = last end
		return self[item]
	end
end

function module.sequence(self, place)
	return module.successor, self, place
end

function module.insert(self, item, place)
	local last = self[self]
	if place == nil then place = last end
	if self[place] ~= nil and addto(self, item, place) == item then
		if place == last then self[self] = item end
		return item
	end
end

function module.removefrom(self, place)
	local last = self[self]
	if place ~= last then
		if place == nil then place = last end
		local item = removeat(self, place)
		if item ~= nil then
			if item == last then self[self] = place end
			return item
		end
	end
end

function module.pushfront(self, item)
	local last = self[self]
	if addto(self, item, last) == item then
		if last == nil then self[self] = item end
		return item
	end
end

function module.popfront(self)
	local last = self[self]
	if self[last] == last then
		self[self] = nil
	end
	return module.removefrom(self, last)
end

function module.pushback(self, item)
	local last = self[self]
	if addto(self, item, last) == item then
		self[self] = item
		return item
	end
end

function module.__tostring(self)
	local result = { "[ " }
	for item in module.sequence(self) do
		result[#result+1] = tostring(item)
		result[#result+1] = ", "
	end
	local last = #result
	result[last] = (last == 1) and "[]" or " ]"
	return concat(result)
end

-- set aliases
module.add = module.pushback

-- stack aliases
module.push = module.pushfront
module.pop = module.popfront
module.top = module.first

-- queue aliases
module.enqueue = module.pushback
module.dequeue = module.popfront
module.head = module.first

return module
