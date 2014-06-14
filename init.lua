-- Workbench mod by MirceaKitsune

--
-- Internal workbench functions:
--

local function move_items(s_inv, s_listname, d_inv, d_listname)
	local s_size = s_inv:get_size(s_listname)
	for i = 1, s_size do
		local stack = s_inv:get_stack(s_listname, i)
		if stack and not stack:is_empty() then
			d_inv:add_item(d_listname, stack)
		end
	end
	s_inv:set_list(s_listname, {})
end

local function set_craft_size(player, size)
	local inv = player:get_inventory()
	if inv:get_size("craft") ~= size*size then
		move_items(inv, "craft", inv, "main")
		inv:set_size("craft", size*size)
		inv:set_width("craft", size)
	end
end

local function set_craft_formspec(player, size)
	local formspec =
	"size[8,"..(size+4.5).."]"
	.."list[current_player;main;0,"..(size+0.5)..";8,4;]"
	.."list[current_player;craft;"..(6-size)..",0;"..size..","..size..";]"
	.."list[current_player;craftpreview;7,"..(size/2-0.5)..";1,1;]"
	player:set_inventory_formspec(formspec)
end

local function set_craft(player, size)
	-- When size is nil, we want to set the default inventory craft
	if not size then
		if minetest.setting_getbool("creative_mode") then
			set_craft_size(player, 3)
			creative_inventory.set_creative_formspec(player, 1, 1)
		elseif minetest.setting_getbool("inventory_crafting_full") then
			set_craft_size(player, 3)
			set_craft_formspec(player, 3)
		else
			set_craft_size(player, 2)
			set_craft_formspec(player, 2)
		end
	else
		size = math.min(6, math.max(1, size))
		set_craft_size(player, size)
		set_craft_formspec(player, size)
	end
end

minetest.register_on_joinplayer(function(player)
	set_craft(player, _)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "workbench:workbench" and fields.quit then
		set_craft(player, _)
	end
end)

--
-- Item definitions:
--

minetest.register_node("workbench:workbench", {
	description = "WorkBench",
	tiles = {"workbench_top.png", "workbench_bottom.png", "workbench_side.png",
		"workbench_side.png", "workbench_side.png", "workbench_front.png"},
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Workbench")
	end,
	on_rightclick = function(pos, node, clicker)
		set_craft(clicker, 3)
		minetest.show_formspec(clicker:get_player_name(), "workbench:workbench", clicker:get_inventory_formspec())
	end,
})

minetest.register_craft({
	output = 'workbench:workbench',
	recipe = {
		{'group:wood', 'group:wood', ''},
		{'group:wood', 'group:wood', ''},
		{'', '', ''},
	}
})
