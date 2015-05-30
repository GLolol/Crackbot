permissions = {}
--insert host into permissions here
--example: permissions["Powder/Developer/cracker64"] = 101
--Owner should be 101

--Get perm value for part of a hostmask (usually just host)
function getPerms(host)
	if permissions[host] then return permissions[host] end
	local highest=-99
	for k,v in pairs(permissions) do
		if host:find(k) then
			if v>highest then
				highest=v
			end
		end
	end
	if highest < -1 then highest=0 end
	return highest
end

--This has server specific data
local config = {
	--Network to connect to, change to whatever network you use
	network = {
		server = "irc.freenode.net",
		port = 6667,
		--password = ""
	},
	--User info, set these to whatever you need
	user = {
		nick = "crekbut",
		username = "crekbut",
		realname = "because",
		
		--account = "Crackbot",
		--password = "password"
	},
	--Owner info, only used now for terminal input
	owner = {
		nick = "GLolol",
		host = "localhost",
		fullhost = "GLolol!GLolol@localhost",
	},
	--Channels to join on start
	autojoin = {
		"##powder-bots",
		"##GLolol",
	},
	--used occasionally to kick people in games.lua
	primarychannel = "##GLolol",
	--logs all commands done in pm, and added aliases
	logchannel = "##Glolol-t",
	
	prefix = "%=",
	suffix = "",
	
	--turns on terminal input, can be used on linux to input commands directly from a second terminal
	terminal = "gnome-terminal -x",
	terminalinput = false,

    -- List of plugins to load
    plugins = {
        "games.lua",
        "alias.lua",
        "ircmodes.lua",
        "filters.lua",
    },
}

return config
