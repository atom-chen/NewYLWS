local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20952 = BaseClass("Skill20952", SkillBase)


function Skill20952:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    -- 武器精通 
    -- 打磨武器，使普通攻击附加{y1}%的法术伤害。持续{A}秒
    -- 打磨武器，使普通攻击附加{y2}%的法术伤害，攻击速度增加{z2}%。持续{A}秒
    
    performer:AddEffect(202703)

    local atkPercent = 0
    if self.m_level >= 3 then
        atkPercent = FixDiv(self:Z(), 100)
    end
    local giver = StatusGiver.New(performer:GetActorID(), 20952)
    local nanManBuff = StatusFactoryInst:NewStatusNanManBuff(giver, FixIntMul(self:A(), 1000), self:Y(), atkPercent, self.m_skillCfg)
    self:AddStatus(performer, performer, nanManBuff)
end

return Skill20952