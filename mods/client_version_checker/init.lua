minetest.register_node("client_version_checker:this_is_the_signature_of_crafter00111010010001000011110000110011",{})

local client_versions = {}
local client_version_channels = {}
local client_has_clientmod = {}

--I needed to add in a dev cycle to adopt for a decimal place error
local current_development_cycle = "alpha"
local current_version = 0.07000

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
    client_version_channels[name] = minetest.mod_channel_join(name..":client_version_channel")
    client_has_clientmod[name] = nil
    minetest.after(5, function()
		if client_has_clientmod[name] then
			client_has_clientmod[name] = nil
		else
			minetest.chat_send_player(name, minetest.colorize("orange", "It seems like you don't have Crafter client installed."
				.. " You will not be able to use all features of this server without the clientmod."
				.. " Please dowload it here: https://github.com/EliasFleckenstein03/crafter_client"))
		end
    end)
end)

minetest.register_on_modchannel_message(function(channel_name, sender, message)
    local channel_decyphered = channel_name:gsub(sender,"")
    if channel_decyphered == ":client_version_channel" then
		client_has_clientmod[sender] = true
        local version = tonumber(message)
        if type(version) ~= "number" then
            minetest.chat_send_player(sender, minetest.colorize("yellow", "Please do not try to crash the server."))
            for i = 1,5 do
                minetest.log("warning", sender.." tried to crash the server!")
            end
        elseif type(version) == "number" then
            if current_development_cycle == "alpha" and version > 0.0999 then
                minetest.chat_send_player(sender, minetest.colorize("yellow", "Please update your client mod."))
                minetest.log("warning", sender.." logged in with an outdated client.")
            elseif version < current_version then
                minetest.chat_send_player(sender, minetest.colorize("yellow", "You need to update your clientmod. Your client version: ")..
                minetest.colorize("white",version)..minetest.colorize("yellow",". Current server version: ").. minetest.colorize("white",current_version)..
                minetest.colorize("yellow",". The game might not work as intended or crash."))
                minetest.log("warning", sender.." logged in with an outdated client.")
            elseif version > current_version then
                minetest.chat_send_player(sender, minetest.colorize("yellow", "Your client mod is new than the server version. Your client version: ")..
                minetest.colorize("white",version)..minetest.colorize("yellow",". Current server version: ")..
                minetest.colorize("white",current_version)..minetest.colorize("yellow",". The game might not work as intended or crash."))
                minetest.log("warning", sender.." logged in with a client new than the server version.")
            end
        end
    end
end)

