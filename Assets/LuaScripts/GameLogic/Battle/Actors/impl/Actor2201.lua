local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local StatusEnum = StatusEnum
local Formular = Formular
local table_insert = table.insert
local table_remove = table.remove
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local MediumManagerInst = MediumManagerInst

local Actor2200 = require "GameLogic.Battle.Actors.impl.Actor2200"
local Actor2201 = BaseClass("Actor2201", Actor2200)

function Actor2201:__init() 
    self.m_22012TakeAtk = false
    self.m_22012B = 0
end   


function Actor2201:OnBorn(create_param)
    Actor.OnBorn(self, create_param) 

    local skillItem22012 = self.m_skillContainer:GetActiveByID(22012)
    if skillItem22012 then
        local Level22012 = skillItem22012:GetLevel()
        local skillCfg22012 = ConfigUtil.GetSkillCfgByID(22012) 
        if skillCfg22012 then
            self.m_22012B = SkillUtil.B(skillCfg22012, Level22012) 
        end
    end
end

function Actor2201:Get22012B()
    return self.m_22012B
end

function Actor2201:Launch22012TakeAtk()
    self.m_22012TakeAtk = true
end

function Actor2201:Reset22012TakeAtk()
    self.m_22012TakeAtk = false
end

function Actor2201:Get22012TakeAtk()
    return self.m_22012TakeAtk 
end
 
return Actor2201