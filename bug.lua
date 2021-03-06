local RChamps = {"Blitzcrank"}
if not table.contains(RChamps, myHero.charName) then print("" ..myHero.charName.. " Is Not Supported!") return end

local Retarded = MenuElement({type = MENU, id = "Retarded", name = "Retarded - "..myHero.charName, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..myHero.charName..".png"})
Retarded:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
Retarded:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
Retarded:MenuElement({type = MENU, id = "KillSteal", name = "Killsteal Settings"})
Retarded:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
Retarded:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
--------------------------------------------------------------------------------
--[[Custom]]
--------------------------------------------------------------------------------
local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

function GetEnemyCount(range)
    local count = 0
    for i=1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if hero.team ~= myHero.team then
            count = count + 1
        end
    end
    return count
end

function CountAlliesInRange(point, range)
	if type(point) ~= "userdata" then error("{CountAlliesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
	local range = range == nil and math.huge or range 
	if type(range) ~= "number" then error("{CountAlliesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
	local n = 0
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isAlly and not unit.isMe and IsValidTarget(unit, range, false, point) then
			n = n + 1
		end
	end
	return n
end

local function CountEnemiesInRange(point, range)
	if type(point) ~= "userdata" then error("{CountEnemiesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
	local range = range == nil and math.huge or range 
	if type(range) ~= "number" then error("{CountEnemiesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
	local n = 0
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if IsValidTarget(unit, range, true, point) then
			n = n + 1
		end
	end
	return n
end

local _EnemyHeroes
function GetEnemyHeroes()
	if _EnemyHeroes then return _EnemyHeroes end
	_EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isEnemy then
			table.insert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local _AllyHeroes
function GetAllyHeroes()
	if _AllyHeroes then return _AllyHeroes end
	_AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isAlly then
			table.insert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

function GetBuffs(unit)
    T = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(T, Buff)
        end
    end
    return T
end

function IsRecalling()
    for K, Buff in pairs(GetBuffs(myHero)) do
        if Buff.name == "recall" and Buff.duration > 0 then
            return true
        end
    end
    return false
end

function GetPercentHP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.health/unit.maxHealth
end

function GetPercentMP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentMP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.mana/unit.maxMana
end

function GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff
		end
	end
	return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacMisc = 0, count = 0}--
end

local function GetBuffs(unit)
	local t = {}
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.count > 0 then
			table.insert(t, buff)
		end
	end
	return t
end

local function GetDistance(p1,p2)
	return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

local function GetDistance2D(p1,p2)
return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2))
end

function IsFacing(unit)
	-- make sure directions are facing opposite:
	local dotProduct = myHero.dir.x*target.dir.x + myHero.dir.z*target.dir.z
	if (dotProduct < 0) then
		-- also make sure you dont have your backs to each other:
		if (myHero.dir.x > 0 and myHero.dir.z > 0) then
			return ((target.pos.x - myHero.pos.x > 0) and (target.pos.z - myHero.pos.z > 0))
		elseif (myHero.dir.x < 0 and myHero.dir.z < 0) then
			return ((target.pos.x - myHero.pos.x < 0) and (target.pos.z - myHero.pos.z < 0))
		elseif (myHero.dir.x > 0 and myHero.dir.z < 0) then
			return ((target.pos.x - myHero.pos.x > 0) and (target.pos.z - myHero.pos.z < 0))
		elseif (myHero.dir.x < 0 and myHero.dir.z > 0) then
			return ((target.pos.x - myHero.pos.x < 0) and (target.pos.z - myHero.pos.z > 0))
		end
	end
	return 1
end

function IsImmune(unit)
	if type(unit) ~= "userdata" then error("{IsImmune}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	for i, buff in pairs(GetBuffs(unit)) do
		if (buff.name == "KindredRNoDeathBuff" or buff.name == "UndyingRage") and GetPercentHP(unit) <= 10 then
			return true
		end
		if buff.name == "VladimirSanguinePool" or buff.name == "JudicatorIntervention" then 
			return true
		end
	end
	return false
end

function HasBuff(unit, buffname)
	if type(unit) ~= "userdata" then error("{HasBuff}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	if type(buffname) ~= "string" then error("{HasBuff}: bad argument #2 (string expected, got "..type(buffname)..")") end
	for i, buff in pairs(GetBuffs(unit)) do
		if buff.name == buffname then 
			return true
		end
	end
	return false
end

function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

function IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if type(range) ~= "number" then error("{IsValidTarget}: bad argument #2 (number expected, got "..type(range)..")") end
	if type(checkTeam) ~= "nil" and type(checkTeam) ~= "boolean" then error("{IsValidTarget}: bad argument #3 (boolean or nil expected, got "..type(checkTeam)..")") end
	if type(from) ~= "nil" and type(from) ~= "userdata" then error("{IsValidTarget}: bad argument #4 (vector or nil expected, got "..type(from)..")") end
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or IsImmune(unit) or (checkTeam and unit.isAlly) then 
		return false 
	end 
	return unit.pos:DistanceTo(from.pos and from.pos or myHero.pos) < range 
end

local _OnVision = {}
function OnVision(unit)
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
	return _OnVision[unit.networkID]
end
Callback.Add("Tick", function() OnVisionF() end)
local visionTick = GetTickCount()
function OnVisionF()
	if GetTickCount() - visionTick > 100 then
		for i,v in pairs(GetEnemyHeroes()) do
			OnVision(v)
		end
	end
end

local _OnWaypoint = {}
function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		-- print("OnWayPoint:"..unit.charName.." | "..math.floor(Game.Timer()))
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
			DelayAction(function()
				local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
					-- print("OnDash: "..unit.charName)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end

local function GetPred(unit,speed,delay)
	local speed = speed or math.huge
	local delay = delay or 0.25
	local unitSpeed = unit.ms
	if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
	if OnVision(unit).state == false then
		local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
		local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unitPos)/speed)))
		if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
		return predPos
	else
		if unitSpeed > unit.ms then
			local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unit.pos)/speed)))
			if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
			return predPos
		elseif IsImmobileTarget(unit) then
			return unit.pos
		else
			return unit:GetPrediction(speed,delay)
		end
	end
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local spellslist = {_Q,_W,_E,_R,SUMMONER_1,SUMMONER_2}
lastcallback = {}

function ReturnState(champion,spell)
	lastcallback[champion.charName..spell.name] = false
end

function ProcessSpellsLoad()
	for i, spell in pairs(spellslist) do
		local tempname = myHero.charName
		lastcallback[tempname..myHero:GetSpellData(spell).name] = false
	end
end

function ProcessSpellCallback()
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.valid then
			for i, spell in pairs(spellslist) do
				local tempname = Hero.charName
				local spelldata = Hero:GetSpellData(spell)
				if spelldata.castTime > Game.Timer() and 
				not lastcallback[tempname..spelldata.name] then
					lastcallback[tempname..spelldata.name] = true
					DelayAction(ReturnState,spelldata.currentCd,{Hero,spelldata})
				end		
			end
		end
	end
end

function EnableMovement()
	--unblock movement
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	castSpell.state = 0
	DelayAction(EnableMovement,0.05)
end

function SecondPosE(pos)
	Control.SetCursorPos(pos)
	Control.KeyUp(HK_E)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function CastSpell(spell,pos)
	local delay = Retarded.Misc.delay:Value()
	local ticker = GetTickCount()
	if castSpell.state == 0 then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
		if ticker - castSpell.tick < Game.Latency() then
			--block movement
			Control.SetCursorPos(pos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			DelayAction(LeftClick,delay/1000,{castSpell.mouse})
			castSpell.casting = ticker + delay
		end
	end
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end
--------------------------------------------------------------------------------
--[[Rectangel]]
--------------------------------------------------------------------------------
local function DrawLine3D(x,y,z,a,b,c,width,col)
  local p1 = Vector(x,y,z):To2D()
  local p2 = Vector(a,b,c):To2D()
  Draw.Line(p1.x, p1.y, p2.x, p2.y, width, col)
end

local function DrawRectangleOutline(x, y, z, x1, y1, z1, width, col)
  local startPos = Vector(x,y,z)
  local endPos = Vector(x1,y1,z1)
  local c1 = startPos+Vector(Vector(endPos)-startPos):Perpendicular():Normalized()*width
  local c2 = startPos+Vector(Vector(endPos)-startPos):Perpendicular2():Normalized()*width
  local c3 = endPos+Vector(Vector(startPos)-endPos):Perpendicular():Normalized()*width
  local c4 = endPos+Vector(Vector(startPos)-endPos):Perpendicular2():Normalized()*width
  DrawLine3D(c1.x,c1.y,c1.z,c2.x,c2.y,c2.z,2,col)
  DrawLine3D(c2.x,c2.y,c2.z,c3.x,c3.y,c3.z,2,col)
  DrawLine3D(c3.x,c3.y,c3.z,c4.x,c4.y,c4.z,2,col)
  DrawLine3D(c1.x,c1.y,c1.z,c4.x,c4.y,c4.z,2,col)
end
--------------------------------------------------------------------------------
--[[Blitzcrank]]
--------------------------------------------------------------------------------	
require("DamageLib")
class "Blitzcrank"
--------------------------------------------------------------------------------
--[[Init]]
--------------------------------------------------------------------------------	
function Blitzcrank:__init()
	print("Retarded - Blitzcrank Loaded...")
	self.Spells = {
		Q = {range = 925, delay = 0.25, speed = 1750,  width = 100},
		W = {range = nil, delay = 0.25, speed = math.huge},
		E = {range = 240, delay = 0.25, speed = 200},
		R = {range = 600, delay = 0.25, speed = math.huge}
	}
	self:Menu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	ProcessSpellsLoad()	
	self.QHit = 0
	self.QTotal = 0
end
--------------------------------------------------------------------------------
--[[Menu]]
--------------------------------------------------------------------------------	
function Blitzcrank:Menu()
	Retarded.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
	Retarded.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	Retarded.Combo:MenuElement({id = "ComboWMax", name = "W Target Distance < ", value = 1050, min = 0, max = 2000, step = 50, tooltip = "Cast W between Min - Max. default = 1050"})
	Retarded.Combo:MenuElement({id = "ComboWMin", name = "W Target Distance > ", value = 700, min = 0, max = 2000, step = 50, tooltip = "Cast W between Min - Max. default = 700"})
    Retarded.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    Retarded.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
    Retarded.Combo:MenuElement({id = "ComboMinR", name = "Min. Targets to R", value = 2, min = 1, max = 5})
    Retarded.Combo:MenuElement({type = MENU, name = "WhiteList", id = "WhiteListQ", tooltip = "Grab only activated Targets!"})
    for K, Enemy in pairs(GetEnemyHeroes()) do
    Retarded.Combo.WhiteListQ:MenuElement({name = Enemy.charName, id = Enemy.charName, value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..Enemy.charName..".png"})
    end
    Retarded.Combo:MenuElement({id = "ComboManaQ", name = "Q Min. Mana", value = 0, min = 0, max = 100, tooltip = "Default is 0%."})
    Retarded.Combo:MenuElement({id = "ComboManaW", name = "W Min. Mana", value = 0, min = 0, max = 100, tooltip = "Default is 0%."})
    Retarded.Combo:MenuElement({id = "ComboManaE", name = "E Min. Mana", value = 0, min = 0, max = 100, tooltip = "Default is 0%."})
    Retarded.Combo:MenuElement({id = "ComboManaR", name = "R Min. Mana", value = 0, min = 0, max = 100, tooltip = "Default is 0%."})

    Retarded.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    Retarded.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
    Retarded.Harass:MenuElement({id = "AutoHarassQ", name = "Harass Q Toggle", key = string.byte("K"), toggle = true})
    Retarded.Harass:MenuElement({type = MENU, name = "WhiteList", id = "WhiteListQ", tooltip = "Grab only activated Targets!"})
    for K, Enemy in pairs(GetEnemyHeroes()) do
    Retarded.Harass.WhiteListQ:MenuElement({name = Enemy.charName, id = Enemy.charName, value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..Enemy.charName..".png"})
    end
    Retarded.Harass:MenuElement({id = "HarassManaQ", name = "Q Min. Mana", value = 25, min = 0, max = 100, tooltip = "Default is 25%."})
    Retarded.Harass:MenuElement({id = "HarassManaE", name = "E Min. Mana", value = 25, min = 0, max = 100, tooltip = "Default is 25%."})

    Retarded.KillSteal:MenuElement({id = "KillStealQ", name = "Use Q", value = true})
    Retarded.KillSteal:MenuElement({id = "KillStealE", name = "Use E", value = true})
    Retarded.KillSteal:MenuElement({id = "KillStealR", name = "Use R", value = true})
    Retarded.KillSteal:MenuElement({id = "KillStealQR", name = "Use Q + R", value = true, tooltip = "Need Q and R KS enabled!"})
    if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
    Retarded.KillSteal:MenuElement({id = "KillStealIgnite", name = "Use Ignite", value = false})
    end
    Retarded.KillSteal:MenuElement({id = "Recall", name = "Disable During Recall", value = true})
    Retarded.KillSteal:MenuElement({id = "Disabled", name = "Disable All", value = false})

    --Retarded.Misc:MenuElement({id = "MiscAutoR", name = "Auto R", value = false})
    --Retarded.Misc:MenuElement({id = "MiscMinR", name = "Min. Targets to Auto R", value = 3, min = 1, max = 5})
    Retarded.Misc:MenuElement({id = "MaxRange", name = "Q Range Limiter", value = 1, min = 0.26, max = 1, step = 0.01, tooltip = "Adjust your Q Range! Recommend = 0.88"})
    Retarded.Misc:MenuElement({type = SPACE, id = "ToolTip", name = "Min Q.Range = 240 - Max Q.Range = 925", tooltip = "Adjust your Q Range! Recommend = 0.88"})
    Retarded.Misc:MenuElement({id = "delay", name = "Spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = "", tooltip = "default is 50."})

    Retarded.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready [?]", value = true, tooltip = "Only draws spells when they're ready"})
    Retarded.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    Retarded.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    Retarded.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    Retarded.Draw:MenuElement({id = "ColorQ", name = "Color Q", color = Draw.Color(255, 249, 0, 4)})
    Retarded.Draw:MenuElement({id = "ColorE", name = "Color E", color = Draw.Color(255, 0, 161, 88)})
    Retarded.Draw:MenuElement({id = "ColorR", name = "Color R", color = Draw.Color(255, 249, 245, 0)})
    Retarded.Draw:MenuElement({id = "DrawWM", name = "Draw W Max/Min", value = false})
    Retarded.Draw:MenuElement({id = "ColorM", name = "Color W Max/Min", color = Draw.Color(255, 169, 104, 255)})
    Retarded.Draw:MenuElement({id = "DrawPred", name = "Draw Pred", value = true})
    Retarded.Draw:MenuElement({id = "WidthALL", name = "Circle Width All", value = 2, min = 1, max = 5, step = 1})
    Retarded.Draw:MenuElement({id = "DisableAll", name = "Disable All", value = false})
end
--------------------------------------------------------------------------------
--[[Tickt]]
--------------------------------------------------------------------------------	
function Blitzcrank:Tick()
	if myHero.dead then return end
	ProcessSpellCallback()
	self:KillSteal()
    self:AutoHarassQ()
    self:GetQCast()
    self:GetQHit()
	local target = _G.SDK.TargetSelector:GetTarget(2000)

	if target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		self:Combo(target)
	elseif target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
		self:Harass(target)
	end
end
--------------------------------------------------------------------------------
--[[Test]]
--------------------------------------------------------------------------------	
    function Blitzcrank:GotBuff(unit, buffName)
        if not unit then print("No Unit given @GotBuff") return false end
        for i = 1, unit.buffCount do
            local buff = unit:GetBuff(i)

            if buff.count > 0 and buff.name == buffName then
            	print(""..buff.count.."")
                return true
            end
        end

        return false
    end

    function Blitzcrank:GetQCast()
        if not self.QCasted then
            local lastTimeQcasted = (myHero:GetSpellData(_Q).castTime - myHero:GetSpellData(_Q).cd)
            if (lastTimeQcasted - Game.Timer() >= -0.1) then
                self.QHitted = false
                self.QCasted = true
                self.QTotal = self.QTotal + 1
            end
        end

        if Ready(_Q) then self.QCasted = false self.QHitted = true end
    end

    function Blitzcrank:GetQHit()
        for K, target in pairs(GetEnemyHeroes()) do
            if not self.QHitted and self.QCasted and self:GotBuff(target, "RocketGrab2") then
                self.QHitted = true
                self.QHit = self.QHit + 1
                self.QCasted = false
            end
        end

        DelayAction(function()
            self.QHitted = true
        end, self.Spells.Q.range/self.Spells.Q.speed)
    end
--------------------------------------------------------------------------------
--[[Combo]]
--------------------------------------------------------------------------------	
function Blitzcrank:Combo(target)
local ComboWMax = Retarded.Combo.ComboWMax:Value()
local ComboWMin = Retarded.Combo.ComboWMin:Value()
local ComboManaQ = Retarded.Combo.ComboManaQ:Value()
local ComboManaW = Retarded.Combo.ComboManaW:Value()
local ComboManaE = Retarded.Combo.ComboManaE:Value()
local ComboManaR = Retarded.Combo.ComboManaR:Value()  

if Ready(_Q) and Retarded.Combo.ComboQ:Value() and Retarded.Combo.WhiteListQ[target.charName]:Value() and IsValidTarget(target, self.Spells.Q.range*Retarded.Misc.MaxRange:Value(), true, myHero.pos) and (myHero.mana/myHero.maxMana >= ComboManaQ/100) then
	local qPred = GetPred(target,math.huge,0.35 + Game.Latency()/1000)
	local qPred2 = GetPred(target,math.huge,1)
	if qPred and qPred2 and target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
	if GetDistance(myHero.pos,qPred2) < self.Spells.Q.range*Retarded.Misc.MaxRange:Value() then
			CastSpell(HK_Q, qPred)
	end
	end
	end
	if Ready(_W) and Retarded.Combo.ComboW:Value() and target.distance < ComboWMax and target.distance > ComboWMin and (myHero.mana/myHero.maxMana >= ComboManaW/100) then
			Control.CastSpell(HK_W)
	end
    if Ready(_E) and Retarded.Combo.ComboE:Value() and IsValidTarget(target, self.Spells.E.range, true, myHero.pos) and (myHero.mana/myHero.maxMana >= ComboManaE/100) then
    		Control.CastSpell(HK_E, target)
    end
    if Ready(_R) and not Ready(_E) and Retarded.Combo.ComboR:Value() and IsValidTarget(target, self.Spells.R.range, true, myHero.pos) and GetEnemyCount() >= Retarded.Combo.ComboMinR:Value() and (myHero.mana/myHero.maxMana >= ComboManaR/100) then
       		Control.CastSpell(HK_R)  
    end
  	end
--------------------------------------------------------------------------------
--[[Harass]]
--------------------------------------------------------------------------------	
function Blitzcrank:Harass(target)
local HarassManaQ = Retarded.Harass.HarassManaQ:Value()
local HarassManaE = Retarded.Harass.HarassManaE:Value()
    if Ready(_Q) and Retarded.Harass.HarassQ:Value() and Retarded.Harass.WhiteListQ[target.charName]:Value() and IsValidTarget(target, self.Spells.Q.range*Retarded.Misc.MaxRange:Value(), true, myHero.pos) and (myHero.mana/myHero.maxMana >= HarassManaQ/100) then
      		local qPred = GetPred(target,math.huge,0.35 + Game.Latency()/1000)
			local qPred2 = GetPred(target,math.huge,1)
			if qPred and qPred2 and target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
				if GetDistance(myHero.pos,qPred2) < self.Spells.Q.range*Retarded.Misc.MaxRange:Value() then
					CastSpell(HK_Q, qPred)
				end
			end

    end
    
    if Ready(_E) and Retarded.Harass.HarassE:Value() and IsValidTarget(target, self.Spells.E.range, true, myHero.pos) and (myHero.mana/myHero.maxMana >= HarassManaE/100) then
  			 Control.CastSpell(HK_E, target)  
    end

end
--------------------------------------------------------------------------------
--[[Autoharass Q]]
--------------------------------------------------------------------------------
function Blitzcrank:AutoHarassQ()
	if Retarded.Harass.AutoHarassQ:Value() and Retarded.Harass.HarassQ:Value() then
    local HarassManaQ = Retarded.Harass.HarassManaQ:Value()
    local target = _G.SDK.TargetSelector:GetTarget(2000)
    if target and Ready(_Q) and IsValidTarget(target, self.Spells.Q.range*Retarded.Misc.MaxRange:Value(), true, myHero.pos) and Retarded.Harass.WhiteListQ[target.charName]:Value() and (myHero.mana/myHero.maxMana >= HarassManaQ/100) then
        local qPred = GetPred(target, math.huge, 0.35 + Game.Latency()/1000)
        local qPred2 = GetPred(target, math.huge,1)
        if qPred and qPred2 and target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
            if GetDistance(myHero.pos,qPred2) < self.Spells.Q.range*Retarded.Misc.MaxRange:Value() then
               CastSpell(HK_Q, qPred)
			end
		end
			end
		end
end
--------------------------------------------------------------------------------
--[[Killsteal]]
--------------------------------------------------------------------------------	
function Blitzcrank:KillSteal()
    if Retarded.KillSteal.Disabled:Value() or (IsRecalling() and Retarded.KillSteal.Recall:Value()) then return end
	for K, target in pairs(GetEnemyHeroes()) do
		if Ready(_Q) and Retarded.KillSteal.KillStealQ:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero.pos) then
			if getdmg("Q", target, myHero) > target.health then
			local qPred = GetPred(target,math.huge,0.35 + Game.Latency()/1000)
			local qPred2 = GetPred(target,math.huge,1)
			if qPred and qPred2 and target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then	
			if GetDistance(myHero.pos,qPred2) < self.Spells.Q.range then
			CastSpell(HK_Q, qPred)
    		end
        end
        	end
        end
        if Ready(_E) and Retarded.KillSteal.KillStealE:Value() and IsValidTarget(target, self.Spells.E.range, true, myHero.pos) then
        	if getdmg("E", target, myHero) > target.health then
                Control.CastSpell(HK_E)
            end
        end
        if Ready(_R) and Retarded.KillSteal.KillStealR:Value() and IsValidTarget(target, self.Spells.R.range, true, myHero.pos) then
        	if getdmg("R", target, myHero) > target.health then
                Control.CastSpell(HK_R)
            end
        end
         if Ready(_Q) and Ready(_R) and Retarded.KillSteal.KillStealQR:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero.pos) then
            if getdmg("Q", target, myHero) + getdmg("R", target, myHero) > target.health then 
            local qPred = GetPred(target,math.huge,0.35 + Game.Latency()/1000)
			local qPred2 = GetPred(target,math.huge,1)
			if qPred and qPred2 and target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then	
			if GetDistance(myHero.pos,qPred2) < self.Spells.Q.range then
			CastSpell(HK_Q, qPred)
            end
        end
        	end
        end
        if myHero:GetSpellData(5).name == "SummonerDot" and Retarded.KillSteal.KillStealIgnite:Value() and Ready(SUMMONER_2) then
            if IsValidTarget(target, 600, true, myHero.pos) and target.health + target.hpRegen*2.5 + target.shieldAD < 50 + 20*myHero.levelData.lvl then
                Control.CastSpell(HK_SUMMONER_2, target)
        end
	end
        if myHero:GetSpellData(4).name == "SummonerDot" and Retarded.KillSteal.KillStealIgnite:Value() and Ready(SUMMONER_1) then
            if IsValidTarget(target, 600, true, myHero.pos) and target.health + target.hpRegen*2.5 + target.shieldAD < 50 + 20*myHero.levelData.lvl then
            	Control.CastSpell(HK_SUMMONER_1, target)	
		end
	end
		end
end
--------------------------------------------------------------------------------
--[[Draws]]
--------------------------------------------------------------------------------				
function Blitzcrank:Draw()
local QHitPos = myHero.pos:To2D()
Draw.Text("Q Stats: "..tostring(self.QHit).." / "..tostring(self.QTotal).."", 20, QHitPos.x + 200, QHitPos.y + 200, Draw.Color(255, 255, 0, 10))

if myHero.dead then return end
	local ComboWMax = Retarded.Combo.ComboWMax:Value()
	local ComboWMin = Retarded.Combo.ComboWMin:Value()
	local Widthall = Retarded.Draw.WidthALL:Value()
	local DrawWM = Retarded.Draw.DrawWM:Value()
	local ColorM = Retarded.Draw.ColorM:Value()
	local DrawPred = Retarded.Draw.DrawPred:Value()
	if Retarded.Draw.DisableAll:Value() then return end
    if Retarded.Draw.DrawReady:Value() then
        if Ready(_Q) and Retarded.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, ""..tostring(self.Spells.Q.range * Retarded.Misc.MaxRange:Value()).."", Retarded.Draw.WidthALL:Value(), Retarded.Draw.ColorQ:Value())
        end
         if Ready(_E) and Retarded.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, self.Spells.E.range, Retarded.Draw.WidthALL:Value(), Retarded.Draw.ColorE:Value())
        end
        if Ready(_R) and Retarded.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, self.Spells.R.range, Retarded.Draw.WidthALL:Value(), Retarded.Draw.ColorR:Value())
        end
    else
        if Retarded.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, ""..tostring(self.Spells.Q.range * Retarded.Misc.MaxRange:Value()).."", Retarded.Draw.WidthALL:Value(), Retarded.Draw.ColorQ:Value())
        end
         if Retarded.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, self.Spells.E.range, Retarded.Draw.WidthALL:Value(), Retarded.Draw.ColorE:Value())
        end
        if Retarded.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, self.Spells.R.range, Retarded.Draw.WidthALL:Value(), Retarded.Draw.ColorR:Value())
        end
    end
    if DrawWM  and Ready(_W) then
           Draw.Circle(myHero.pos, ComboWMax, Widthall, ColorM)
           Draw.Circle(myHero.pos, ComboWMin, Widthall, ColorM)
    end
    	if DrawPred then 
			local target = _G.SDK.TargetSelector:GetTarget(self.Spells.Q.range)
				if target then
					local Pred = GetPred(target,math.huge,0.35 + Game.Latency()/1000)
						local Pred2 = GetPred(target,math.huge,1)
							if Pred and Pred2 and target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
						Draw.Circle(Pred, self.Spells.Q.width)
     					DrawRectangleOutline(myHero.pos.x, myHero.pos.y, myHero.pos.z, Pred.x, Pred.y, Pred.z, self.Spells.Q.width, col)	

     					Draw.Circle(Pred2, self.Spells.Q.width, Draw.Color(255, 255, 0, 10))
     					DrawRectangleOutline(myHero.pos.x, myHero.pos.y, myHero.pos.z, Pred2.x, Pred2.y, Pred2.z, self.Spells.Q.width, Draw.Color(255, 255, 0, 10))	
				end
			end
		end
    local textPos = myHero.pos:To2D()
    Draw.Text("Q Range: "..tostring(self.Spells.Q.range * Retarded.Misc.MaxRange:Value()).."", 20, textPos.x + 180, textPos.y - 10, Draw.Color(255, 255, 0, 10))
    if Retarded.Harass.AutoHarassQ:Value() then
    Draw.Text("Harass Toggle: On", 20, textPos.x + 180, textPos.y + 10, Draw.Color(255, 255, 0, 10))
    else
    Draw.Text("Harass Toggle: Off", 20, textPos.x + 180, textPos.y + 10, Draw.Color(255, 255, 0, 10))
	end
end

if _G[myHero.charName]() then print("" ..myHero.name.. " Have Fun!!!") end
