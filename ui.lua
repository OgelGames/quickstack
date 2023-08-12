
local S = minetest.get_translator("quickstack")
local FS = function(...)
	return minetest.formspec_escape(S(...))
end
local floor, format, insert, concat = math.floor, string.format, table.insert, table.concat
local quickstack, get_settings, save_settings = ...
local ui = unified_inventory

ui.register_button("quickstack", {
	type = "image",
	image = "quickstack_button.png",
	tooltip = S("Quick stack to nearby chests"),
	action = quickstack,
})

ui.register_button("quickstack_settings", {
	type = "image",
	image = "quickstack_settings.png",
	tooltip = S("Quick stack settings"),
})

local function get_inventory_overlay(player, style)
	local settings = get_settings(player)
	if not settings.qs_show_locked then
		return ""
	end
	local overlay = {}
	for i=1, 32 do
		local x, y = (i-1)%8, floor((i-1)/8)
		if settings["qs_locked_"..i] then
			insert(overlay, format("image[%f,%f;1.25,1.25;quickstack_lock_overlay.png]",
				style.std_inv_x + x*1.25, style.std_inv_y + y*1.25))
		end
	end
	return concat(overlay)
end

ui.register_page("quickstack_settings", {get_formspec = function(player, style)
	local settings = get_settings(player)
	local offset = style.is_lite_mode and 0.7 or 1.0
	local formspec = {
		style.standard_inv_bg,
		format("label[%f,%f;%s]", style.form_header_x, style.form_header_y, FS("Quick stack settings")),
		format("tooltip[%f,%f;6.7,3.3;%s]",
			style.std_inv_x + 0.1, offset, FS("Locked inventory slots are not quick stacked")),
		format("image_button[%f,%f;0.75,0.75;ui_locked.png;qs_lock_all;]tooltip[qs_lock_all;%s]",
			style.std_inv_x + 7.35, offset, FS("Lock all inventory slots")),
		format("image_button[%f,%f;0.75,0.75;ui_unlocked.png;qs_unlock_all;]tooltip[qs_unlock_all;%s]",
			style.std_inv_x + 8.2, offset, FS("Unlock all inventory slots")),
	}
	for i=1, 32 do
		local x, y = (i-1)%8, floor((i-1)/8)
		if settings["qs_locked_"..i] then
			insert(formspec, format("image_button[%f,%f;0.75,0.75;quickstack_lock_icon.png;%s;]",
				style.std_inv_x + 0.1 + x*0.85, offset + y*0.85, "qs_unlock_"..i))
		else
			insert(formspec, format("button[%f,%f;0.75,0.75;%s;]",
				style.std_inv_x + 0.1 + x*0.85, offset + y*0.85, "qs_lock_"..i))
		end
	end
	local checkboxes = {
		{"qs_lock_tools",  FS("Lock tools"),  FS("Tools are not quick stacked")},
		{"qs_exact_match", FS("Exact match"), FS("Only items with matching metadata are quick stacked")},
		{"qs_show_locked", FS("Show locked"), FS("Locked slots are shown in the inventory")},
	}
	for i, box in ipairs(checkboxes) do
		local checked = settings[box[1]] and "true" or "false"
		insert(formspec, format("checkbox[%f,%f;%s;%s;%s]tooltip[%s;%s]",
			style.std_inv_x + 7.35, offset + 1.2 + (i-1)*0.6, box[1], box[2], checked, box[1], box[3]))
	end
	return {formspec = concat(formspec)}
end})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not player or not fields or formname ~= "" then
		return
	end
	local settings = get_settings(player)
	local update_formspec = false
	for i=1, 32 do
		if (fields.qs_lock_all or fields["qs_lock_"..i]) and not settings["qs_locked_"..i] then
			settings["qs_locked_"..i] = true
			update_formspec = true
		elseif (fields.qs_unlock_all or fields["qs_unlock_"..i]) and settings["qs_locked_"..i] then
			settings["qs_locked_"..i] = nil
			update_formspec = true
		end
	end
	for _,box in pairs({"qs_lock_tools", "qs_exact_match", "qs_show_locked"}) do
		if fields[box] then
			settings[box] = fields[box] == "true" and true or nil
			update_formspec = true
		end
	end
	if update_formspec then
		save_settings(player, settings)
		minetest.sound_play("ui_click", {to_player=player:get_player_name(), gain = 0.1})
		ui.set_inventory_formspec(player, "quickstack_settings")
	end
end)

minetest.register_on_mods_loaded(function()
	for _,page in pairs(ui.pages) do
		local old_get_formspec = page.get_formspec
		page.get_formspec = function(player, style)
			local formspec = old_get_formspec(player, style)
			if formspec.draw_inventory ~= false then
				local overlay = get_inventory_overlay(player, style)
				formspec.formspec = formspec.formspec..overlay
			end
			return formspec
		end
	end
end)
