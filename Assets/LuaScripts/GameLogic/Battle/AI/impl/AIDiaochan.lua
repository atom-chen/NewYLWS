local ConfigUtil = ConfigUtil
local SkillPoolInst = SkillPoolInst

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIDiaochan = BaseClass("AIDiaochan", AIManual)

function AIDiaochan:SelectNormalSkill(target)
    if self.m_selfActor:GetSkill10483A() > 0 and self.m_selfActor:Get1048AtkCount() >= self.m_selfActor:GetSkill10483A() then
        self.m_selfActor:ClearAtkCount()
        local skillItem = self.m_selfActor:GetSkillContainer():GetPassiveByID(10483)
        if skillItem then
            return SKILL_CHK_RESULT.OK, skillItem
        end
    end

    local normalSkill = self.m_selfActor:GetSkillContainer():GetNextAtk()
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
return AIDiaochan