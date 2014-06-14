-- Workbench mod by MirceaKitsune

-- Moves items from one inventory to another
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

-- Resizes the player's craft area
local function craft_resize(player, size)
	if not size then
		-- Default size: 3 in creative, 2 otherwise
		if minetest.setting_getbool("creative_mode") or
		minetest.setting_getbool("inventory_crafting_full") then
			size = 3
		else
			size = 2
		end
	end

	local inv = player:get_inventory()
	if inv:get_width("craft") ~= size then
		move_items(inv, "craft", inv, "main")
		inv:set_width("craft", size)
		inv:set_size("craft", size*size)
		return size
	end
end

local function get_formspec(size)
	size = math.min(6, math.max(1, size))
	local formspec =
		"size[8,"..(size+4.5).."]"
		.."list[current_player;main;0,"..(size+0.5)..";8,4;]"
		.."list[current_player;craft;0,0;"..size..","..size..";]"
		.."list[current_player;craftpreview;6,"..(size/2-0.5)..";1,1;]"
	return formspec
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "workbench:workbench" then
		if fields.quit then
			craft_resize(player, _)
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	local size = craft_resize(player, _)
	if size and size ~= 3 then
		player:set_inventory_formspec("size[8,7.5]"
			.."list[current_player;main;0,3.5;8,4;]"
			.."list[current_player;craft;3,0.5;2,2;]"
			.."list[current_player;craftpreview;6,1;1,1;]")
	end
end)

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
		craft_resize(clicker, 3)
		minetest.show_formspec(clicker:get_player_name(), "default:workbench", get_formspec(3))
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
