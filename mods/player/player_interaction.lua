--hurt sound and disable fall damage group handling
minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if reason.type == "fall" then
		if minetest.get_item_group(minetest.get_node(player:get_pos()).name, "disable_fall_damage") > 0 then
			return(0)
		end
	end
	if hp_change < 0 then
		minetest.sound_play("hurt", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
	end
	return(hp_change)
end, true)

--throw all items on death
minetest.register_on_dieplayer(function(player, reason)
	local pos = player:getpos()
	local inv = player:get_inventory()
	
	for i = 1,inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		local name = stack:get_name()
		local count = stack:get_count()
		if name ~= "" then
			local obj = minetest.add_item(pos, name.." "..count)
			if obj then
				obj:setvelocity(vector.new(math.random(-3,3),math.random(4,8),math.random(-3,3)))
			end
			inv:set_stack("main", i, ItemStack(""))
		else
			inv:set_stack("main", i, ItemStack(""))
		end
	end
end)


--this dumps the players crafting table on closing the inventory
dump_craft = function(player)
	local inv = player:get_inventory()
	local pos = player:getpos()
	pos.y = pos.y + player:get_properties().eye_height
	for i = 1,inv:get_size("craft") do
		local item = inv:get_stack("craft", i)
		local obj = minetest.add_item(pos, item)
		if obj then
			local x=math.random(-2,2)*math.random()
			local y=math.random(2,5)
			local z=math.random(-2,2)*math.random()
			obj:setvelocity({x=x, y=y, z=z})
		end
		inv:set_stack("craft", i, nil)
	end
end


--play sound to keep up with player's placing vs inconsistent client placing sound 
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local node = minetest.registered_nodes[newnode.name]
	local sound = node.sounds
	local placing = ""
	if sound then
		placing = sound.placing
	end
	--only play the sound when is defined
	if type(placing) == "table" then
		minetest.sound_play(placing.name, {
			  pos = pos,
			  gain = placing.gain,
			  --pitch = math.random(60,100)/100
		})
	end
end)

--replace stack when empty (building)
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local old = itemstack:get_name()
	--pass through to check
	minetest.after(0,function(pos, newnode, placer, oldnode, itemstack, pointed_thing,old)
		if not placer then
			return
		end
		local new = placer:get_wielded_item():get_name()
		if old ~= new and new == "" then
			local inv = placer:get_inventory()
			--check if another stack
			if inv:contains_item("main", old) then
				--print("moving stack")
				--run through inventory
				for i = 1,inv:get_size("main") do
					--if found set wielded item and remove old stack
					if inv:get_stack("main", i):get_name() == old then
						local count = inv:get_stack("main", i):get_count()
						placer:set_wielded_item(old.." "..count)
						inv:set_stack("main",i,ItemStack(""))	
						minetest.sound_play("pickup", {
							  to_player = player,
							  gain = 0.7,
							  pitch = math.random(60,100)/100
						})
						return				
					end
				end
			end
		end
	end,pos, newnode, placer, oldnode, itemstack, pointed_thing,old)
end)

--this throws the player when they're punched
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	dir = vector.multiply(dir,10)
	local vel = player:get_player_velocity()
	dir.y = 0
	if vel.y <= 0 then
		dir.y = 7
	end
	player:add_player_velocity(dir)
end)
