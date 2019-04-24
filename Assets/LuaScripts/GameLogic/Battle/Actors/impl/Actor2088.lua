local FixAdd = FixMath.add
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local FixDiv = FixMath.div
local Actor2057 = require "GameLogic.Battle.Actors.impl.Actor2057"
local Actor2088 = BaseClass("Actor2088", Actor2057)
local base = Actor2057

function Actor2088:__init()
    self.m_stealAtkCountList = {}
    self.m_20883Y = 0
    self.m_20883A = 0
    self.m_20883XPercent = 0
    self.m_stealedTargetList = {}
end

function Actor2088:OnBorn(create_param)
    base.OnBorn(self, create_param)
    
    local skillItem = self.m_skillContainer:GetPassiveByID(20883)
    if skillItem  then
        local skillCfg = ConfigUtil.GetSkillCfgByID(20883)
        local level = skillItem:GetLevel()
        if skillCfg then
            if skillItem:GetLevel() >= 3 then
                self.m_20883Y = SkillUtil.Y(skillCfg, level)
            end
            self.m_20883A = SkillUtil.A(skillCfg, level)
            self.m_20883XPercent = FixDiv(SkillUtil.X(skillCfg, level), 100)
        end
    end
end


function Actor2088:Get20883X()
    return self.m_20883XPercent
end

function Actor2088:Get20883Y()
    return self.m_20883Y
end

function Actor2088:Get20883A()
    return self.m_20883A
end

function Actor2088:Get2088StealAtkCount(targetID)
    return self.m_stealAtkCountList[targetID] or 0
end

function Actor2088:Add2088StealAtkCount(targetID)
    if not self.m_stealAtkCountList[targetID] then
        self.m_stealAtkCountList[targetID] = 1
    else
        self.m_stealAtkCountList[targetID] = FixAdd(self.m_stealAtkCountList[targetID], 1)
    end
end

function Actor2088:AddStealedTarget(targetID)
    if not self.m_stealedTargetList[targetID] then
        self.m_stealedTargetList[targetID] = true   
    end
end

function Actor2088:GetStealedTarget(targetID)
    local isStealed = false
    if self.m_stealedTargetList[targetID] then
        isStealed = true
    end

    return isStealed
end

return Actor2088