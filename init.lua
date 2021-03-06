if IRC_RUNNING then error("Already running") end
IRC_RUNNING=true
WINDOWS = package.config:sub(1,1) == "\\"
dofile("derp.lua")
dofile("irc/init.lua")

filename = arg[1] or "config.lua"

local s,r = pcall(dofile,filename)
if not s then
	if r:find("No such file or directory") then
		print("Config not found, copying template")
		os.execute("cp configtemplate.lua config.lua")
		r=dofile(filename)
	else
		error(r)
	end
end
config = r

local sleep=require "socket".sleep
socket = require"socket"
local console=socket.tcp()
console:settimeout(5)

if not WINDOWS and config.terminalinput then
	--start my console line-in
	os.execute(config.terminal.." lua consolein.lua")
end
shutdown = false
user = config.user
irc=irc.new(user)

--support multiple networks sometime
irc:connect(config.network.server,config.network.port,config.network.password)
config.network.password = nil
if config.user.password then
	irc:sendChat("NickServ", "identify "..config.user.account.." "..config.user.password)
	config.user.password = nil
end
print("Connected")

local connected=false
if not WINDOWS then
	--connect to console thread
	function conConnect()
		console:connect("localhost",1337)
		console:settimeout(0)
		console:setoption("keepalive",true)
		connected=true
	end
	conConnect()
end

dofile("hooks.lua")
dofile("commands.lua")
if #config.autojoin <= 0 then print("No autojoin channels set in config.lua!") end
for k,v in pairs(config.autojoin) do
	irc:join(v)
end
--join extra config channels if they for some reason aren't in the autojoin
if config.primarychannel then
	irc:join(config.primarychannel)
end
if config.logchannel then
	irc:join(config.logchannel)
end

local function consoleThink()
	if not connected then return end
	local line, err = console:receive()
	if line then
		if line:find("[^%s%c]") then
			consoleChat(line)
		end
	end
end
didSomething=false
while true do
	if shutdown then irc:shutdown() break end
	irc:think()
	consoleThink()
	ircSendOne()
	timerCheck()
	if not didSomething then
		sleep(0.05)
	else
		sleep(0.01)
	end
	didSomething=false
end
