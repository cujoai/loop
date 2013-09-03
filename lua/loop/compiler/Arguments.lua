--------------------------------------------------------------------------------
---------------------- ##       #####    #####   ######  -----------------------
---------------------- ##      ##   ##  ##   ##  ##   ## -----------------------
---------------------- ##      ##   ##  ##   ##  ######  -----------------------
---------------------- ##      ##   ##  ##   ##  ##      -----------------------
---------------------- ######   #####    #####   ##      -----------------------
----------------------                                   -----------------------
----------------------- Lua Object-Oriented Programming ------------------------
--------------------------------------------------------------------------------
-- Project: LOOP Class Library                                                --
-- Release: 2.3 beta                                                          --
-- Title  : Command-line Argument Processor                                   --
-- Author : Renato Maia <maia@inf.puc-rio.br>                                 --
-- Date   : 2007-07-10                                                        --
--------------------------------------------------------------------------------

local _G = require "_G"
local select   = _G.select
local tonumber = _G.tonumber
local type     = _G.type

local oo = require "loop.base"

local module = oo.class{
	_badnumber = "invalid value for option '%s', number excepted but got '%s'",
	_missing = "no value defined for option '%s'",
	_unknown = "unknown option '%s'",
	_norepeat = "option '%s' was already defined",
	_optpat = "^%-(%w+)(=?)(.-)$",
	_boolean = {
		["true"] = true,
		["false"] = false,
		yes = true,
		no = false,
	},
}

function module.__call(self, ...)
	local errmsg
	local defined = self._norepeat and {} or nil
	local count = select("#", ...)
	local pos = 1
	while pos <= count do
		local opt, set, val = select(pos, ...):match(self._optpat)
		if not opt then break end
		
		-- apply option alias
		local temp = self._alias
		temp = temp and temp[opt]
		opt = temp or opt
		
		-- check repeated definitions
		local kind = type(self[opt])
		if defined then
			if not defined[opt] then
				defined[opt] = true
			elseif kind ~= "table" and kind ~= "function" then
				pos, errmsg = nil, self._norepeat:format(opt)
				break
			end
		end
		
		-- process option value
		if kind == "boolean" then
			if set == "" then -- option value was not given, assume the value 'true'
				val = true
			else
				temp = self._boolean[val]
				if temp ~= nil then val = temp end
			end
			self[opt] = val
		elseif kind == "nil" and self._unknown then
			pos, errmsg = nil, self._unknown:format(opt)
			break
		else
			if set == "" then -- option value was not given, get following argument
				pos = pos + 1
				if pos <= count then
					val = select(pos, ...)
				else
					pos, errmsg = nil, self._missing:format(opt)
					break
				end
			end
			
			if kind == "number" then
				local number = tonumber(val)
				if number == nil then
					pos, errmsg = nil, self._badnumber:format(opt, val)
					break
				end
				self[opt] = number
			elseif kind == "function" then
				errmsg = self[opt](self, opt, val)
				if errmsg then
					pos = nil
					break
				end
			elseif kind == "table" then
				local list = self[opt]
				list[#list+1] = val
			else
				self[opt] = val
			end
		end
		pos = pos + 1
	end
	return pos, errmsg
end

return module