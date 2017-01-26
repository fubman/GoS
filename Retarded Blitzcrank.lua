class "Blitzcrank"

require('DamageLib')

function Blitzcrank:__init()
    if myHero.charName ~= "Blitzcrank" then return end
    PrintChat("[Retarded] Blitzcrank - Loaded....")
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end
--[[Spells]]
function Blitzcrank:LoadSpells()
    Q = {Range = 925, width = nil, Delay = 0.25, Radius = 0, Speed = 1750, Collision = true, aoe = false, type = "linear"}
    W = {Range = nil, width = nil, Delay = 0.25, Radius = 0, Speed = 0, Collision = false, aoe = false, type = "linear"}
    E = {Range = 240, width = nil, Delay = 0.25, Radius = 0, Speed = 200, Collision = false, aoe = false, type = "circular"}
    R = {Range = 600, width = 200, Delay = 0.25, Radius = 0, Speed = 0, Collision = false, aoe = true, type = "circular"}
end
--[[Menu Icons]]
local Icons = {
    ["C"] = "http://static.lolskill.net/img/champions/64/blitzcrank.png",
    ["Q"] = "http://static.lolskill.net/img/abilities/64/Blitzcrank_RocketGrab.png",
    ["W"] = "http://static.lolskill.net/img/abilities/64/Blitzcrank_Overdrive.png",
    ["E"] = "http://static.lolskill.net/img/abilities/64/Blitzcrank_PowerFist.png",
    ["R"] = "http://static.lolskill.net/img/abilities/64/Blitzcrank_StaticField.png"
}
--[[Spell Data]]
local qSpellData = myHero:GetSpellData(_Q);
local wSpellData = myHero:GetSpellData(_W);
local eSpellData = myHero:GetSpellData(_E);
local rSpellData = myHero:GetSpellData(_R);

function Blitzcrank:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "Blitzcrank", name = "[Retarded] - Blitzcrank", leftIcon=Icons["C"]})

    --[[Combo]]
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({type = MENU, name = "WhiteList", id = "WhiteListQ", tooltip = "Grab only activated Targets!"})
    for K, Enemy in pairs(self:GetEnemyHeroes()) do
    self.Menu.Combo.WhiteListQ:MenuElement({name = Enemy.charName, id = Enemy.charName, value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..Enemy.charName..".png"})
    end

    --[[Harass]]
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
    self.Menu.Harass:MenuElement({id = "HarassToggle", name = "Harass Toggle", value = false})
    --[[self.Menu.Harass:MenuElement({id = "HarassToggle", name = "Harass Toggle", key = string.byte("H"), toggle = true})]]
    self.Menu.Harass:MenuElement({type = MENU, name = "WhiteList", id = "WhiteListQ", tooltip = "Grab only activated Targets!"})
    for K, Enemy in pairs(self:GetEnemyHeroes()) do
    self.Menu.Harass.WhiteListQ:MenuElement({name = Enemy.charName, id = Enemy.charName, value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..Enemy.charName..".png"})
    end
    self.Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 25, min = 0, max = 100, tooltip = "Default is 25%."})

    --[[KillSteal]]
    self.Menu:MenuElement({type = MENU, id = "KillSteal", name = "KillSteal Settings"})
    self.Menu.KillSteal:MenuElement({id = "KillStealQ", name = "Use Q", value = true})
    self.Menu.KillSteal:MenuElement({id = "KillStealR", name = "Use R", value = false})
    if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
    self.Menu.KillSteal:MenuElement({id = "KillStealIgnite", name = "Use Ignite", value = false})
    end
    self.Menu.KillSteal:MenuElement({id = "Recall", name = "Disable During Recall", value = true})
    self.Menu.KillSteal:MenuElement({id = "Disabled", name = "Disable All", value = false})

    --[[Misc]]
    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
    self.Menu.Misc:MenuElement({id = "MaxRange", name = "Q Range Limiter", value = 1, min = 0.26, max = 1, step = 0.01, tooltip = "Adjust your Q Range! Recommend = 0.88"})
    self.Menu.Misc:MenuElement({type = SPACE, id = "ToolTip", name = "Min Q.Range = 240 - Max Q.Range = 925", tooltip = "Adjust your Q Range! Recommend = 0.88"})

    --[[Draw]]
    self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Menu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawDamage", name = "Draw Damage", value = true})
end
--[[Update]]
function Blitzcrank:Tick()
    if myHero.dead then return end
        local target = self:GetTarget(2000)
            --self:KillSteal()
            self:AutoHarass()
                 if EOW:Mode() == "Combo" then
                  self:Combo()
                end
            if EOW:Mode() == "Harass" then
        self:Harass()
    end
end
--[[Combo]]
function Blitzcrank:Combo(target)
local target = self:GetTarget(2000)
    if target then 
    if self.Menu.Combo.ComboQ:Value() and self.Menu.Combo.WhiteListQ[target.charName]:Value() then
    self:CastQ(target)   
    end
    
    if self.Menu.Combo.ComboE:Value() then
    self:CastE(target)   
        end
    end
end
--[[Harass]]
function Blitzcrank:Harass()
local target = self:GetTarget(2000)

    if target then 
    if self.Menu.Harass.HarassQ:Value() and self.Menu.Harass.WhiteListQ[target.charName]:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value()/100) then
    self:CastQ(target)   
    end
    
    if self.Menu.Harass.HarassE:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value()/100) then
    self:CastE(target)   
        end
    end
end

--[[Auto Harass]]
function Blitzcrank:AutoHarass(target)
    local target = self:GetTarget(2000)
    if target then 
        if self.Menu.Harass.HarassQ:Value() then
        if self.Menu.Harass.HarassToggle:Value() and myHero.mana > self.Menu.Harass.HarassMana:Value() then
                for _, Enemy in pairs(self:GetEnemyHeroes()) do
                        if self.Menu.Harass.WhiteListQ[target.charName]:Value() then
                                self:CastQ(target) 
                    end
                end
            end
        end
    end
end

function Blitzcrank:CastQ(target)
    local target = self:GetTarget(2000)
    if target and self:CanCast(_Q) and self:IsValidTarget(target, Q.Range, false, myHero.pos) then
    local qTarget = self:GetTarget(Q.Range * self.Menu.Misc.MaxRange:Value())
    if qTarget and target:GetCollision(Q.Range) == 0 then
    local castPos = target:GetPrediction(Q.Delay)
    Control.CastSpell(HK_Q, castPos)
        end
    end
end

function Blitzcrank:CastW(target)
    if target then
        Control.CastSpell(HK_W, position)
    end
end

function Blitzcrank:CastE(target)
    local target = self:GetTarget(2000)
    if target --[[and self.IsReady(_E) and self:IsValidTarget(target, E.Range, false, myHero.pos)]] then
    local eTarget = self:GetTarget(E.Range)
        if eTarget then 
            Control.CastSpell(HK_E)
    end
    end
end

function Blitzcrank:CastR(target)
    local target = self:GetTarget(2000)
    if target and self.IsReady(_R) and self:IsValidTarget(target, R.Range, false, myHero.pos) then
    local rTarget = self:GetTarget(R.Range)
        if rTarget then 
            Control.CastSpell(HK_R)
        end
    end
end

function Blitzcrank:Draw()
    if myHero.dead then return end

    if self.Menu.Draw.DrawReady:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, ""..tostring(Q.Range * self.Menu.Misc.MaxRange:Value()).."", 3, Draw.Color(255, 255, 0, 10))
        end
        if self:IsReady(_E) and self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, E.Range, 3, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_R) and self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, rSpellData.range, 3, Draw.Color(255, 255, 255, 255))
        end
    else
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, ""..tostring(Q.Range * self.Menu.Misc.MaxRange:Value()).."", 3, Draw.Color(255, 255, 0, 10))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, E.ange, 3, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, rSpellData.range, 3, Draw.Color(255, 255, 255, 255))
        end
    end

    local textPos = myHero.pos:To2D()
    Draw.Text("Q Range: "..tostring(Q.Range * self.Menu.Misc.MaxRange:Value()).."", 20, textPos.x + 180, textPos.y - 10, Draw.Color(255, 255, 0, 10))
    --Draw.Text("Harass: "..tostring(self.Menu.Harass.HarassToggle:Value()).."", 20, textPos.x + 60, textPos.y + 5, Draw.Color(255, 255, 0, 10))

    if self.Menu.Harass.HarassToggle:Value() == true then
    return Draw.Text("Harass Toggle: On", 20, textPos.x + 180, textPos.y + 5, Draw.Color(255, 255, 0, 10))
    else
     Draw.Text("Harass Toggle: Off", 20, textPos.x + 180, textPos.y + 5, Draw.Color(255, 255, 0, 10))
end
end

function Blitzcrank:GetEnemyHeroes()
    self.EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isEnemy then
            table.insert(self.EnemyHeroes, Hero)
        end
    end
    return self.EnemyHeroes
end

function Blitzcrank:GetTarget(range)
    local GetEnemyHeroes = self:GetEnemyHeroes()
    local Target = nil
        for i = 1, #GetEnemyHeroes do
        local Enemy = GetEnemyHeroes[i]
        if self:IsValidTarget(Enemy, range, false, myHero.pos) then
            Target   = Enemy
        end
    end
    return Target
end

function Blitzcrank:GetAllyHeroes()
    self.AllyHeroes = {}
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isAlly and not Hero.isMe then
            table.insert(self.AllyHeroes, Hero)
        end
    end
    return self.AllyHeroes
end

function Blitzcrank:GetFarmTarget(range)
    local target
    for j = 1,Game.MinionCount() do
        local minion = Game.Minion(j)
        if self:IsValidTarget(minion, range) and minion.team ~= myHero.team then
            target = minion
            break
        end
    end
    return target
end

function Blitzcrank:GetPercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

function Blitzcrank:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end

function Blitzcrank:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function Blitzcrank:GetBuffs(unit)
    self.T = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.T, Buff)
        end
    end
    return self.T
end

function Blitzcrank:GetBuffData(unit, buffname)
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.name:lower() == buffname:lower() and Buff.count > 0 then
            return Buff
        end
    end
    return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

function Blitzcrank:IsRecalling()
    for K, Buff in pairs(self:GetBuffs(myHero)) do
        if Buff.name == "recall" and Buff.duration > 0 then
            return true
        end
    end
    return false
end

function Blitzcrank:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Blitzcrank:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Blitzcrank:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Blitzcrank:IsValidTarget(unit, range, checkTeam, from)
    local range = range == nil and math.huge or range
    if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable --[[or self:IsImmune(unit)]] or (checkTeam and unit.isAlly) then 
        return false 
    end 
    return unit.pos:DistanceTo(from and from or myHero) < range 
end

--[[Standart IsImmune]]
--[[
function Blitzcrank:IsImmune(unit)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if (Buff.name == "kindredrnodeathbuff" or Buff.name == "undyingrage") and self:GetPercentHP(unit) <= 10 then
            return true
        end
        if Buff.name == "vladimirsanguinepool" or Buff.name == "judicatorintervention" then 
            return true
        end
    end
    return false
end
]]
function OnLoad()
    Blitzcrank()
end
