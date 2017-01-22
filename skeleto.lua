class "AlqoholicSkeleton"

require('DamageLib')

local _shadow = myHero.pos

function AlqoholicSkeleton:__init()
    if myHero.charName ~= "CHAMP NAME HERE" then return end
    PrintChat("[AlqoholicSkeleton] Initiated")
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function AlqoholicSkeleton:LoadSpells()
    Q = {Range = 0, Delay = 0, Radius = 0, Speed = 0}
    W = {Range = 0, Delay = 0, Radius = 0, Speed = 0}
    E = {Range = 0, Delay = 0, Radius = 0, Speed = 0}
    R = {Range = 0, Delay = 0, Radius = 0, Speed = 0}
    PrintChat("[AlqoholicSkeleton] Spells Loaded")
end

function AlqoholicSkeleton:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "AlqoholicSkeleton", name = "Alqohol - AlqoholicSkeleton", leftIcon="https://puu.sh/tq0A8/5b42557aa9.png"})

    --[[Combo]]
    self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
    self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    self.Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
    --[[Harass]]
    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.Menu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
    self.Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
    self.Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --[[Farm]]
    self.Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
    self.Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
    self.Menu.Farm:MenuElement({id = "FarmW", name = "Use W", value = true})
    self.Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
    self.Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --[[Misc]]
    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})

    --[[Draw]]
    self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Menu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target [?]", value = true, tooltip = "Draws current target"})

    PrintChat("[AlqoholicSkeleton] Menu Loaded")
end

function AlqoholicSkeleton:Tick()

    -- Put everything you want to update every time the game ticks here (don't put too many calculations here or you'll drop FPS)

    if self:Mode() == "Combo" then
        self:Combo()
    elseif self:Mode() == "Harass" then
        self:Harass()
    elseif self:Mode() == "Farm" then
        self:Farm()
    elseif self:Mode() == "LastHit" then
        self:LastHit()
    end
end

function AlqoholicSkeleton:Combo()
    -- COMBO LOGIC HERE
end

function AlqoholicSkeleton:Harass()
    -- HARASS LOGIC HERE
end

function AlqoholicSkeleton:Farm()
    -- FARM LOGIC HERE
end

function AlqoholicSkeleton:LastHit()
    -- LASTHIT LOGIC HERE
end

function AlqoholicSkeleton:CastQ(position)
    if position then
        Control.CastSpell(HK_Q, position)
    end
end

function AlqoholicSkeleton:CastW(position)
    if position then
        Control.CastSpell(HK_W, position)
    end
end

function AlqoholicSkeleton:CastE(position)
    if position then
        Control.CastSpell(HK_E, position)
    end
end

function AlqoholicSkeleton:CastR(target)
    if target then
        Control.CastSpell(HK_R, target)
    end
end

function AlqoholicSkeleton:Draw()
    if myHero.dead then return end

    if self.Menu.Draw.DrawReady:Value() then
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_W) and self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_E) and self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self:IsReady(_R) and self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, R.Range, 1, Draw.Color(255, 255, 255, 255))
        end
    else
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, R.Range, 1, Draw.Color(255, 255, 255, 255))
        end
    end

    local textPos = myHero.pos:To2D()
    Draw.Text("THIS IS TEXT", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))

    if self.Menu.Draw.DrawTarget:Value() then
        local drawTarget = self:GetTarget(Q.Range)
        if drawTarget then
            Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
        end
    end
end

function AlqoholicSkeleton:Mode()
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

function AlqoholicSkeleton:GetTarget(range)
    local target
    for i = 1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
            target = hero
            break
        end
    end
    return target
end

function AlqoholicSkeleton:GetFarmTarget(range)
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

function AlqoholicSkeleton:GetPercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

function AlqoholicSkeleton:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end

function AlqoholicSkeleton:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function AlqoholicSkeleton:GetBuffs(unit)
    self.T = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.T, Buff)
        end
    end
    return self.T
end

function AlqoholicSkeleton:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function AlqoholicSkeleton:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function AlqoholicSkeleton:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function AlqoholicSkeleton:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

function OnLoad()
    AlqoholicSkeleton()
end