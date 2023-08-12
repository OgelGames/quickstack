
local S = minetest.get_translator("quickstack")
local MP = minetest.get_modpath("quickstack")

local function get_settings(player)
	local str = player:get_meta():get("quickstack_settings")
	if not str then
		return {}
	end
	str = minetest.parse_json(str)
	return str or {}
end

local function save_settings(player, settings)
	local str = minetest.write_json(settings)
	player:get_meta():set_string("quickstack_settings", str)
end

local quickstack = loadfile(MP.."/quickstack.lua")(get_settings)

loadfile(MP.."/ui.lua")(quickstack, get_settings, save_settings)

minetest.register_chatcommand("qs", {
	description = S("Quick stack to nearby chests"),
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false
		end
		quickstack(player)
		return true
	end
})
