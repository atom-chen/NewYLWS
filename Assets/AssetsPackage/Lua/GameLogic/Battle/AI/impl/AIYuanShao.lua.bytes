local ConfigUtil = ConfigUtil
local SkillCheckResult = SkillCheckResult
local SkillUtil = SkillUtil
local SkillPoolInst = SkillPoolInst

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIYuanShao = BaseClass("AIYuanShao", AIManual)

function AIYuanShao:SelectNormalSkill(target)
    local normalSkill = nil
    if self.m_selfActor:IsChangeAtkWay() then
        normalSkill = self.m_selfActor:GetSkillContainer():GetAtkByIdx(3)
    else
        normalSkill = self.m_selfActor:GetSkillContainer():GetNextAtk()
    end

    if normalSkill then
        local skillcfg = ConfigUtil.GetSkillCfgByID(normalSkill:GetID())
        if skillcfg then
            local skillbase = SkillPoolInst:GetSkill(skillcfg, normalSkill:GetLevel())
            if skillbase then
                local ret = skillbase:CheckPerform(self.m_selfActor, target)
                if ret ~= SKILL_CHK_RESULT.OK then
                    return ret
                end

                if not self:IsCDOK(normalSkill) then
                    return SKILL_CHK_RESULT.CD 
                end

                return SKILL_CHK_RESULT.OK, normalSkill
            end
        end
    end

    return SKILL_CHK_RESULT.ERR
end
return AIYuanShao