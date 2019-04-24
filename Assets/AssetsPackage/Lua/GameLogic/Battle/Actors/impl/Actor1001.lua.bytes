local StatusEnum = StatusEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1001 = BaseClass("Actor1001", Actor)

function Actor1001:__init()
    self.m_10013A = 0
    self.m_10013B = 0
    self.m_10013XPercent = 0
    self.m_10013Y = 0
end

function Actor1001:Get10013A()
    return self.m_10013A
end

function Actor1001:Get10013B()
    return self.m_10013B
end

function Actor1001:Get10013X()
    return self.m_10013XPercent
end

function Actor1001:Get10013Y()
    return self.m_10013Y
end

function Actor1001:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    -- 被动：刘备天潢贵胄，无法被控制状态连续命中。控制状态：眩晕、定身、冰冻、睡眠、恐惧
    local skillItem = self.m_skillContainer:GetPassiveByID(10013)
    if skillItem then
        local skillLevel = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10013)
        if skillCfg then
            self.m_10013A = FixIntMul(SkillUtil.A(skillCfg, skillLevel), 1000)
            self.m_10013B = SkillUtil.B(skillCfg, skillLevel)
            self.m_10013Y = SkillUtil.Y(skillCfg, skillLevel)
            self.m_10013XPercent = FixDiv(SkillUtil.X(skillCfg, skillLevel), 100)
        end
 
        if skillLevel >= 5 then
            local giver = StatusGiver.New(self:GetActorID(), 10013)
            local immuneIntervalControlBuff = StatusFactoryInst:NewStatusImmuneIntervalControl(giver)
            immuneIntervalControlBuff:AddImmuneIntervalFlag(StatusEnum.IMMUNEFLAG_CONTROL)
            immuneIntervalControlBuff:SetCanClearByOther(false)
            self:GetStatusContainer():Add(immuneIntervalControlBuff, self)
        end
    end
end

return Actor1001