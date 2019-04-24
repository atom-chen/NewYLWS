local FixAdd = FixMath.add
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1048 = BaseClass("Actor1048", Actor)

function Actor1048:__init()
    self.m_atkCount = 0
    self.m_10483A = 0
    
    self.m_originalPos = 0
end

function Actor1048:Add1048AtkCount(count)
    self.m_atkCount = FixAdd(self.m_atkCount, count)
end

function Actor1048:ClearAtkCount(count)
    self.m_atkCount = 0
end

function Actor1048:Get1048AtkCount(count)
    return self.m_atkCount
end

function Actor1048:GetSkill10483A()
    return self.m_10483A
end

function Actor1048:GetOriginalPos()
    return self.m_originalPos
end

function Actor1048:SetOriginalPos(pos)
    self.m_originalPos = pos
end

function Actor1048:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    
    local skillItem = self.m_skillContainer:GetPassiveByID(10483)
    if skillItem then
        local skillCfg = ConfigUtil.GetSkillCfgByID(10483)
        if skillCfg then
            self.m_10483A = SkillUtil.A(skillCfg, skillItem:GetLevel())
        end
    end
end

function Actor1048:OnAttackEnd(skillCfg)
    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
    Actor.OnAttackEnd(self, skillCfg)
end

function Actor:LogicOnFightEnd()
    self.m_atkCount = 0 
end

return Actor1048