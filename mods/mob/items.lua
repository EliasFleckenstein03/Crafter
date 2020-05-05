--items
minetest.register_craftitem("mob:raw_porkchop", {
	description = "Raw Porkchop",
	inventory_image = "raw_porkchop.png",
	health = 2,
})
minetest.register_craftitem("mob:cooked_porkchop", {
	description = "Cooked Porkchop",
	inventory_image = "cooked_porkchop.png",
	groups = {satiation=3,hunger=5},
})

minetest.register_craftitem("mob:slimeball", {
	description = "Slimeball",
	inventory_image = "slimeball.png",
})
--cooking
minetest.register_craft({
	type = "cooking",
	output = "mob:cooked_porkchop",
	recipe = "mob:raw_porkchop",
	groups = {satiation=6,hunger=7},
})
