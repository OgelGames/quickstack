
local get_settings = ...
local chest_nodenames, cooldowns = {}, {}

local function can_quickstack(settings, index, stack)
	if stack:is_empty() or settings["qs_locked_"..index] or
			settings.qs_lock_tools and minetest.registered_tools[stack:get_name()] then
		return false
	end
	return true
end

local function find_nearby_chests(player)
	local pos = vector.round(player:get_pos())
	local pos1 = vector.subtract(pos, vector.new(4, 3, 4))
	local pos2 = vector.add(pos, vector.new(4, 3, 4))
	return minetest.find_nodes_in_area(pos1, pos2, chest_nodenames, true)
end

local function stack_to_chest(settings, pos, player, items, allow_put)
	local inv = minetest.get_meta(pos):get_inventory()
	if inv:get_size("main") == 0 or inv:is_empty("main") then
		return
	end
	local items_added = false
	for _,stack in pairs(items) do
		if inv:contains_item("main", stack:peek_item(1), settings.qs_exact_match) then
			local count = stack:get_count()
			if allow_put then
				count = allow_put(pos, "main", nil, stack, player)
			end
			if count and count > 0 then
				local to_add = stack:take_item(count)
				local leftover = inv:add_item("main", to_add)
				if leftover:get_count() < count then
					items_added = true
				end
				stack:add_item(leftover)
			end
		end
	end
	return items_added
end

local function quickstack(player)
	if not player then
		return
	end
	local inv = player:get_inventory()
	if inv:is_empty("main") then
		return
	end
	local player_name = player:get_player_name()
	local now = os.time()
	if cooldowns[player_name] and now < cooldowns[player_name] then
		return
	end
	cooldowns[player_name] = now + 3
	local settings = get_settings(player)
	local items = {}
	for i, stack in pairs(inv:get_list("main")) do
		if can_quickstack(settings, i, stack) then
			items[i] = stack
		end
	end
	if next(items) == nil then
		return
	end
	local chests = find_nearby_chests(player)
	if next(chests) == nil then
		return
	end
	local items_added = false
	for name, positions in pairs(chests) do
		local def = minetest.registered_nodes[name]
		if def then
			local allow_put = def.allow_metadata_inventory_put
			for _,pos in pairs(positions) do
				if stack_to_chest(settings, pos, player, items, allow_put) then
					items_added = true
				end
			end
		end
	end
	if items_added then
		for i, stack in pairs(items) do
			inv:set_stack("main", i, stack)
		end
		minetest.sound_play("quickstack_pop", {to_player = player_name, gain = 0.1})
	end
end

local function setting_to_table(setting)
	local t = {}
	local str = minetest.settings:get(setting)
	if not str then
		return t
	end
	for _,name in pairs(str:split(",")) do
		name = name:trim()
		if minetest.registered_nodes[name] then
			t[name] = true
		end
	end
	return t
end

minetest.register_on_mods_loaded(function()
	local exclude_nodes = setting_to_table("quickstack_exclude_nodes")
	local include_nodes = setting_to_table("quickstack_include_nodes")
	for name, def in pairs(minetest.registered_nodes) do
		if not exclude_nodes[name] then
			if name:find("chest") or def.description and def.description:find("[Cc]hest") then
				include_nodes[name] = true
			end
		end
	end
	for name in pairs(include_nodes) do
		table.insert(chest_nodenames, name)
	end
end)

return quickstack
