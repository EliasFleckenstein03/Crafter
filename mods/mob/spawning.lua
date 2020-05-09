--this is where mob spawning is defined

--spawn mob in a square doughnut shaped radius
local chance = 20
--inner and outer part of square donut radius
local inner = 24
local outer = 128

--for debug testing to isolate mobs
local spawn = true

local spawn_table = {"pig"}
local dark_spawn_table = {"slime","creepig"}
local aether_spawn_table = {"flying_pig"}

local function spawn_mobs()
	print("---------------------------------------------")
	if spawn and global_mob_amount < mob_limit then
		--check through players
		for _,player in ipairs(minetest.get_connected_players()) do
			--don't spawn near dead players
			if player:get_hp() > 0 then
			
				--local mob_number = math.random(0,2)
				
				local int = {-1,1}
				local pos = vector.floor(vector.add(player:getpos(),0.5))
				
				local x,z
				
				--this is used to determine the axis buffer from the player
				local axis = math.random(0,1)
				
				--cast towards the direction
				if axis == 0 then --x
					x = pos.x + math.random(inner,outer)*int[math.random(1,2)]
					z = pos.z + math.random(-outer,outer)
				else --z
					z = pos.z + math.random(inner,outer)*int[math.random(1,2)]
					x = pos.x + math.random(-outer,outer)
				end
				
				local spawner
				if pos.y >= 21000 then
					spawner = minetest.find_nodes_in_area_under_air(vector.new(x,pos.y-32,z), vector.new(x,pos.y+32,z), {"aether:grass"})
				else
					spawner = minetest.find_nodes_in_area_under_air(vector.new(x,pos.y-32,z), vector.new(x,pos.y+32,z), {"main:grass","main:sand","main:water"})
				end
				
				--print(dump(spawner))
				if table.getn(spawner) > 0 then
					local mob_pos = spawner[1]
					--aether spawning
					if mob_pos.y >= 21000 then
						mob_pos.y = mob_pos.y + 1
						local mob_spawning = aether_spawn_table[math.random(1,table.getn(spawn_table))]
						print("Aether Spawning "..mob_spawning.." at: "..minetest.pos_to_string(mob_pos))
						minetest.add_entity(mob_pos,"mob:"..mob_spawning)

					else
						local light_level = minetest.get_node_light(spawner[1])
						if light_level < 10 then
							mob_pos.y = mob_pos.y + 1
							local mob_spawning = dark_spawn_table[math.random(1,table.getn(dark_spawn_table))]
							print("Dark Spawning "..mob_spawning.." at: "..minetest.pos_to_string(mob_pos))
							minetest.add_entity(mob_pos,"mob:"..mob_spawning)
						else
							mob_pos.y = mob_pos.y + 1
							local mob_spawning = spawn_table[math.random(1,table.getn(spawn_table))]
							print("Light Spawning "..mob_spawning.." at: "..minetest.pos_to_string(mob_pos))
							minetest.add_entity(mob_pos,"mob:"..mob_spawning)
						end
					end
				end
			end
		end
	end
	minetest.after(5, function()
		spawn_mobs()
	end)
end

spawn_mobs()
