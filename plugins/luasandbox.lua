module("luasandbox", package.seeall)

--LUA sandbox
local function lua(usr,chan,msg,args,luan)
	if not msg then return "No code" end
	if msg:sub(1,1) =="\27" then
		return "Error: bytecode (?)"
	end
	
	if WINDOWS then
		msg = msg:gsub(".",function(a)return string.char(65+math.floor(a:byte()/16),65+a:byte()%16)end)
		local rf = io.popen("plugins\\sandbox\\luasandbox.exe "..msg)
		local r = rf:read("*a")
		return r:sub(1,#r-1)
	else
		local sdump=""
		luan = luan or "lua"
		--byte the string so you can't escape
		for char in msg:gmatch(".") do sdump = sdump .. "\\"..char:byte() end
		local rf = io.popen(luan..[=[ -e "dofile('derp.lua') dofile('plugins/sandbox/linuxsandbox.lua') local e,err=load_code(']=]..sdump..[=[',nil,'t',env) if e then local r = {pcall(e)} local s = table.remove(r,1) print(unpack(r)) else print(err) end" 2>&1]=])
		coroutine.yield(false,1)
		local kill = io.popen([[pgrep -f "]]..luan..[[ -e"]]):read("*a")
		if kill~="" then os.execute([[pkill -f "]]..luan..[[ -e"]]) end
		local r = rf:read("*a")
		if r=="" and kill and kill~="" then r="Killed" end
		if r then r = r:gsub("[\r\n]"," "):sub(1,500) end
		return r
	end
end
local function lua52(usr,chan,msg,args)
	return lua(usr,chan,msg,args,"lua5.2")
end
add_cmd(lua,"lua",0,"Runs sandbox lua code, '/lua <code>'",true)
if not WINDOWS then
	add_cmd(lua52,"5.2",0,"Runs sandbox lua5.2 code, '/lua <code>'",false)
end
