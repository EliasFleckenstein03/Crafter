local time = 0

minetest.register_globalstep(function(dtime)
	time = time + dtime

	if time < 0.5 then
		return
	end
	
	time = 0

	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		local node_head = minetest.get_node(vector.add(pos, vector.new(0, 1.5, 0))).name

		-- Is player suffocating inside node? (Only for solid full opaque cube type nodes
		-- without group disable_suffocation=1)
		local ndef = minetest.registered_nodes[node_head]

		if ndef
		and (ndef.walkable == nil or ndef.walkable == true)
		and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
		and (ndef.node_box == nil or ndef.node_box.type == "regular")
		and (ndef.groups.disable_suffocation ~= 1)
		and (node_head ~= "ignore")
		and (not minetest.check_player_privs(name, {noclip = true})) then
			if player:get_hp() > 0 then
				player:set_hp(player:get_hp() - 1)
			end
		end

	end

end)
