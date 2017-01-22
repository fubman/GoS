
class "Ezreal"
if myHero.charName ~= "Ezreal" then return end

--[[Locals]]
local leveltracker = 0
local Scriptname,Version,Author,LV = "[Retarded] Ezreal","1.0","FubMaN","7.1"
local Icons = {
    ["C"] = "http://static.lolskill.net/img/champions/64/ezreal.png",
    ["Q"] = "http://static.lolskill.net/img/abilities/64/Ezreal_MysticShot.png",
    ["W"] = "http://static.lolskill.net/img/abilities/64/Ezreal_EssenceFlux.png",
    ["E"] = "http://static.lolskill.net/img/abilities/64/Ezreal_ArcaneShift.png",
    ["R"] = "http://static.lolskill.net/img/abilities/64/Ezreal_TrueshotBarrage.png"
}
local Names = {
    ["QN"] = "(Q)",
    ["WN"] = "(W)",
    ["EN"] = "(E)",
    ["RN"] = "(R)"
}  


local qSpellData = myHero:GetSpellData(_Q);
local wSpellData = myHero:GetSpellData(_W);
local eSpellData = myHero:GetSpellData(_E);
local rSpellData = myHero:GetSpellData(_R);

require("DamageLib")

--[[onload scriptsw :D]]
function OnLoad() Ezreal() end
	Callback.Add('Load',function()
	PrintChat(""..Scriptname.." - Loaded !!!")
end)


function Ezreal:__init()
	Callback.Add("Draw", function() self:Draw() end)
	self:LoadTables()
    Callback.Add("Tick", function() self:Tick() end)
	self:Menu()

end
--[[Load End Ezreal]]




--[[Menu]]
function Ezreal:Menu()

	self.Config = MenuElement({type = MENU, name = ""..Scriptname.."", id = "Ezreal", leftIcon = Icons["C"]})

--[[Combo]]
	self.Config:MenuElement({type = MENU, name = "Combo", id = "Combo"})
--Q Enabke / Slider(Mana)
	self.Config.Combo:MenuElement({name = Names["QN"], id = "ComboQ", leftIcon = Icons["Q"], value = true})
	self.Config.Combo:MenuElement({id = "ComboManaQ", name = "Min. Mana % (Q)", value = 5, min = 0, max = 100})
	self.Config.Combo:MenuElement({type = "SPACE"})
--W Enable / Slider(Mana)
	self.Config.Combo:MenuElement({name = Names["WN"], id = "ComboW", leftIcon = Icons["W"], value = true})
	self.Config.Combo:MenuElement({id = "ComboManaW", name = "Min. Mana % (W)", value = 5, min = 0, max = 100})
	self.Config.Combo:MenuElement({type = "SPACE"})
--R Enable / Slider(Mana/Hit)
	self.Config.Combo:MenuElement({name = Names["RN"], id = "ComboR", leftIcon = Icons["R"], value = true})
	self.Config.Combo:MenuElement({id = "ComboManaR", name = "Min. Mana % (R)", value = 15, min = 0, max = 100})
	self.Config.Combo:MenuElement({id = "ComboHitR", name = "Min. Hit (R)", value = 2, min = 1, max = 5})

--[[Harass]]
	self.Config:MenuElement({type = MENU, name = "Harass", id = "Harass"})
--Q Enbale / Slider(Mana)
	self.Config.Harass:MenuElement({name = Names["QN"], id = "HarraQ", leftIcon = Icons["Q"], value = true})
	self.Config.Harass:MenuElement({id = "HarassManaQ", name = "Min. Mana % (Q)", value = 50, min = 0, max = 100})
--Spacer
	self.Config.Harass:MenuElement({type = "SPACE"})
--W Enable / Slider(Mana)
	self.Config.Harass:MenuElement({name = Names["WN"], id = "W", leftIcon = Icons["W"], value = true})
	self.Config.Harass:MenuElement({id = "HarassManaW", name = "Min. Mana % (W)", value = 50, min = 0, max = 100})

--[[Clear]]
	self.Config:MenuElement({type = MENU, name = "Clear", id = "Clear"})
--Spacer / Title
	self.Config.Clear:MenuElement({type = SPACE, name = "Wave Clear"})
	self.Config.Clear:MenuElement({type = SPACE})
--Wave Clear Q / Slider(Mana)
	self.Config.Clear:MenuElement({name = Names["QN"], id = "WClearQ", leftIcon = Icons["Q"], value = true})
	self.Config.Clear:MenuElement({id = "WClearMana", name = "Min. Mana %", value = 50, min = 0, max = 100})
--Spacer / Title
	self.Config.Clear:MenuElement({type = SPACE})
	self.Config.Clear:MenuElement({type = SPACE, name = "Jungle Clear"})
	self.Config.Clear:MenuElement({type = SPACE})
--Jungle Clear Q/E / Slider(Mana)
	self.Config.Clear:MenuElement({name = Names["QN"], id = "JClearQ", leftIcon = Icons["Q"], value = true})
	self.Config.Clear:MenuElement({id = "JClearMana", name = "Min. Mana %", value = 50, min = 0, max = 100})



--[[Misc]]
  self.Config:MenuElement({type = MENU, name = "Misc", id = "Misc"})

  self.Config.Misc:MenuElement({type = MENU, name = "Auto Level", id = "AutoLvl"})
  self.Config.Misc.AutoLvl:MenuElement({id = "AutoLevel", name = "Auto Level", value =false}) -- uselevl
  self.Config.Misc.AutoLvl:MenuElement({id = "LevelOrder", name = "Level Logic", value =7, drop = {"Q>W>E", "Q>E>W","W>Q>E","W>E>Q","E>W>Q", "E>Q>W","Default"}}) --logic
  self.Config.Misc.AutoLvl:MenuElement({id = "Level1", name = "Level 1 Spell Off", value =true}) --donot


--[[Draws]]
	self.Config:MenuElement({type = MENU, name = "Draw", id = "Draw"})
--Disable All Draws
	self.Config.Draw:MenuElement({name = "Disable All Draws", id = "Disabled", value = false})
--Q Draw
	self.Config.Draw:MenuElement({name = Names["QN"], id = "ColorQ", leftIcon = Icons["Q"], color = Draw.Color(43, 255, 0, 255)})
	self.Config.Draw:MenuElement({type = Menu, id = "AColorQ", name = "Draw (Q)", value = true})
--W Draw
	self.Config.Draw:MenuElement({name = Names["WN"], id = "ColorW", leftIcon = Icons["W"], color = Draw.Color(255, 204, 0, 255)})
	self.Config.Draw:MenuElement({type = Menu, id = "AColorW", name = "Draw (W)", value = true})
--E Draw
	self.Config.Draw:MenuElement({name = Names["EN"], id = "ColorE", leftIcon = Icons["E"], color = Draw.Color(255, 115, 255, 255)})
	self.Config.Draw:MenuElement({type = Menu, id = "AColorE", name = "Draw (E)", value = true})
--R Draw
	self.Config.Draw:MenuElement({name = Names["RN"], id = "ColorR", leftIcon = Icons["R"], color = Draw.Color(255, 0, 157, 255)})
	self.Config.Draw:MenuElement({type = Menu, id = "AColorR", name = "Draw (R)", value = true})

local leveltracker = 0

  self.Config:MenuElement({id = "blank", type = SPACE , name = ""})
  self.Config:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LV.. ""})
  self.Config:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})

end

--[[MODE]]
function Ezreal:Mode()
    if Orbwalker["Combo"].__active then
        return "Combo"
    elseif Orbwalker["Harass"].__active then
        return "Harass"
    elseif Orbwalker["Farm"].__active then
        return "Farm"
    elseif Orbwalker["LastHit"].__active then
        return "LastHit"
    end
    return ""
end

--[[CAST Q]]



function Ezreal:Combo(target)
	if self.Menu.Combo.ComboQ:Value() then
		self:CastQ(target)
end
end

function Ezreal:CastQ(target)
	if target then
				local castPos = target:GetPrediction(Q.Speed, Q.Delay)
				Control.CastSpell(HK_Q, castPos)
			end
		end






--[[Draws]]
function Ezreal:Draw()
	if myHero.dead then return end

	if self.Config.Draw.Disabled:Value() then return end

	if self.Config.Draw.AColorQ:Value() and Misc:IsReady(_Q) then
		Draw.Circle(myHero.pos,qSpellData.range,4, self.Config.Draw.ColorQ:Value())
	end

	if self.Config.Draw.AColorW:Value() and Misc:IsReady(_W) then
		Draw.Circle(myHero.pos,wSpellData.range,4, self.Config.Draw.ColorW:Value())
	end

	if self.Config.Draw.AColorE:Value() and Misc:IsReady(_E) then
		Draw.Circle(myHero.pos,eSpellData.range,4, self.Config.Draw.ColorE:Value())
	end

	if self.Config.Draw.AColorR:Value() and Misc:IsReady(_R) then
		Draw.Circle(myHero.pos,rSpellData.range,4, self.Config.Draw.ColorR:Value())
	end
end

--[[Spell Rdy Check]]
class "Misc"
function Misc:IsReady(slot)
	if myHero:GetSpellData(slot).currentCd < 0.01 and myHero.mana > myHero:GetSpellData(slot).mana then
		return true
	end
	return false
end

--[[AutoLevel]]
local leveltracker = 0

function Ezreal:Tick()
  self:LevelLogic()
end

local slotcheck =nil

function Ezreal:LevelLogic()
  local levelorder = LevelChooseOrder[self.Config.Misc.AutoLvl.LevelOrder:Value()][myHero.levelData.lvl-myHero.levelData.lvlPts+1] 
  local leveldefaultorder =LevelDefaultOrder[myHero.charName][myHero.levelData.lvl-myHero.levelData.lvlPts+1]              

  if myHero.levelData.lvlPts >0 then
    if os.clock()-leveltracker >0.75 and self.Config.Misc.AutoLvl.AutoLevel:Value() and (levelorder  ~= nil and leveldefaultorder  ~= nil)then
      if (self.Config.Misc.AutoLvl.Level1:Value() and myHero.levelData.lvl ==1) then return end
      Control.KeyDown(HK_LUS)
      if self.Config.Misc.AutoLvl.LevelOrder:Value() == 7 then
        Control.KeyDown(leveldefaultorder)
        slotcheck =leveldefaultorder
      else
        Control.KeyDown(levelorder)
        slotcheck =levelorder
      end
      leveltracker = os.clock()
    end
  else
    if Control.IsKeyDown(HK_LUS) then
      Control.KeyUp(HK_LUS)
    end
    if slotcheck ~= nil  then
      if Control.IsKeyDown(slotcheck) then
        Control.KeyUp(slotcheck)
      end
    end
  end
end

function Ezreal:LoadTables()
  LevelChooseOrder = {
    [1]={ HK_Q,HK_W,HK_E,HK_Q,HK_Q,HK_R,HK_Q,HK_W,HK_Q,HK_W,HK_R,HK_W,HK_W,HK_E,HK_E,HK_R,HK_E,HK_E},
    [2]= { HK_Q,HK_W,HK_E,HK_Q,HK_Q,HK_R,HK_Q,HK_E,HK_Q,HK_E,HK_R,HK_E,HK_E,HK_W,HK_W,HK_R,HK_W,HK_W},
    [3]={ HK_W,HK_E,HK_Q,HK_W,HK_W,HK_R,HK_W,HK_Q,HK_W,HK_Q,HK_R,HK_Q,HK_Q,HK_E,HK_E,HK_R,HK_E,HK_E},
    [4]={ HK_W,HK_E,HK_Q,HK_W,HK_W,HK_R,HK_W,HK_E,HK_W,HK_E,HK_R,HK_E,HK_E,HK_Q,HK_Q,HK_R,HK_Q,HK_Q},
    [5]={ HK_E,HK_Q,HK_W,HK_E,HK_E,HK_R,HK_E,HK_W,HK_E,HK_W,HK_R,HK_W,HK_W,HK_Q,HK_Q,HK_R,HK_Q,HK_Q},
    [6]= { HK_E,HK_Q,HK_W,HK_E,HK_E,HK_R,HK_E,HK_Q,HK_E,HK_Q,HK_R,HK_Q,HK_Q,HK_W,HK_W,HK_R,HK_W,HK_W},
    [7]= { HK_E,HK_Q,HK_W,HK_E,HK_E,HK_R,HK_E,HK_W,HK_E,HK_W,HK_R,HK_W,HK_W,HK_Q,HK_Q,HK_R,HK_Q,HK_Q},
  }

  LevelDefaultOrder = {
    ["Ezreal"] = {HK_Q, HK_E, HK_W, HK_Q, HK_Q, HK_R, HK_Q, HK_E, HK_Q, HK_E, HK_R, HK_E, HK_E, HK_W, HK_W, HK_R, HK_W, HK_W},
  }
end

