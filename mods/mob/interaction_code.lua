--this is the file which houses the functions that control how mobs interact with the world


--this controls what happens when the mob gets punched
pig.on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
	local hp = self.object:get_hp()
	
	if (self.punched_timer <= 0 and hp > 1) or puncher == self.object then
		self.hostile = true
		self.hostile_timer = 20
		self.punched_timer = 0.8
		local hurt = tool_capabilities.damage_groups.fleshy
		if not hurt then
			hurt = 1
		end
		
		self.object:set_hp(hp-hurt)
		if hp > 1 then
			minetest.sound_play("pig", {object=self.object, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
		end
		
		self.hp = hp-hurt
		

		self.direction = vector.multiply(dir,-1)
		self.speed = 5

		dir = vector.multiply(dir,10)
		dir.y = 4
		self.object:add_velocity(dir)
	elseif self.punched_timer <= 0 and self.death_animation_timer == 0 then
		self.death_animation_timer = 1
		minetest.sound_play("pig_die", {object=self.object, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
	end
end

--this is what happens when a mob diese
pig.on_death = function(self, killer)
	local pos = self.object:getpos()
	--pos.y = pos.y + 0.4
	minetest.sound_play("mob_die", {pos = pos, gain = 1.0})
	minetest.add_particlespawner({
		amount = 40,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.new(-5,-5,-5),
		maxvel = vector.new(5,5,5),
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "smoke.png",
	})
	local obj = minetest.add_item(pos,"mob:raw_porkchop")
	self.child:get_luaentity().parent = nil
end

--this makes the mob rotate and then die
pig.manage_death_animation = function(self,dtime)
	if self.death_animation_timer > 0 then
		self.death_animation_timer = self.death_animation_timer - dtime
		
		local self_rotation = self.object:get_rotation()
		
		if self_rotation.z < math.pi/2 then
			self_rotation.z = self_rotation.z + (dtime*2)
			self.object:set_rotation(self_rotation)
		end
		
		--print(self.death_animation_timer)
		local currentvel = self.object:getvelocity()
		local goal = vector.new(0,0,0)
		local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
		acceleration = vector.multiply(acceleration, 0.05)
		self.object:add_velocity(acceleration)
		self.object:set_animation({x=0,y=0}, 15, 0, true)
		self.return_head_to_origin(self,dtime)
		
		if self.death_animation_timer < 0 then
			print("dead")
			self.object:punch(self.object, 2, 
						{
						full_punch_interval=1.5,
						damage_groups = {fleshy=2},
					})
		end
	end
end

--the pig will look for and at players
pig.look_around = function(self,dtime)
	local pos = self.object:get_pos()
	
	--this is where the mob is actually looking
	--local eye_ray = self.raycast_look(self,dtime)
	--this is below where the mob is pointed, checks if ledge
	--[[ --work on this later
	local ledge_ray = self.look_below(self)
		
	local is_a_drop = true
	--check if there's a drop
	if ledge_ray then
		for pointed_thing in ledge_ray do
			if pointed_thing then
				local pos2 = pointed_thing.under
				local distance = math.floor(vector.subtract(pos2,pos).y-self.object:get_properties().collisionbox[2]+0.5+0.5)
				if distance >= -3 then
					is_a_drop = false
				end
			end
		end
	end
	--turn around
	if is_a_drop == true then
		self.direction = vector.multiply(self.direction, -1)
		print("turning around")
	end
	]]--
	
	--a mob will check if it needs to jump
	if eye_ray then
		for pointed_thing in eye_ray do
			local pos = self.object:get_pos()
			local pos2 = pointed_thing.under
			local walkable
			if minetest.registered_nodes[minetest.get_node(pos2).name] then
				walkable = minetest.registered_nodes[minetest.get_node(pos2).name].walkable
			end
			if walkable then
				if vector.distance(pos,pos2) < 1 then
					self.jump(self)
					break
				end
			end
		end
	end
	
	
	--STARE O_O
	--and follow!
	self.following = false
	local player_found = false
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
		if object:is_player() and player_found == false and object:get_hp() > 0 then
			--look at player's camera
			local pos2 = object:get_pos()
			pos2.y = pos2.y + 1.625
			
			player_found = true
			
			self.move_head(self,pos2,dtime)
			
			if self.hostile == true then
				self.direction = vector.direction(pos,pos2)
				local distance = vector.distance(pos,pos2)-2
				if distance < 0 then
					distance = 0
				end
				
				--punch the player
				if distance < 1 and self.punch_timer <= 0 and object:get_hp() > 0 then
					self.punch_timer = 1
					object:punch(self.object, 2, 
						{
						full_punch_interval=1.5,
						damage_groups = {fleshy=2},
					},vector.direction(pos,pos2))
				end
				self.speed = distance * 3
				self.following = true
			end
			--only look at one player
			break
		end
	end
	--stare straight if not found
	if player_found == false then
		self.move_head(self,nil,dtime)
		self.manage_hostile_timer(self,dtime)
	end
end