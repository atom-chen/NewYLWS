local ConfigUtil = ConfigUtil
local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local FixSub = FixMath.sub

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIGongSunZan = BaseClass("AIGongSunZan", AIManual)

function AIGongSunZan:GetAiType()
    return BattleEnum.AITYPE_GONGSUNZAN
end

function AIGongSunZan:SelectSkill(target, includeDazhao)
    if not target then return nil end
    if includeDazhao == nil then includeDazhao = true end

    if not self.m_selfActor:GetStatusContainer():CanAnySkill() then
        return nil
    end

    local skillContainer = self.m_selfActor:GetSkillContainer()
    local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID

    local selectSkill = skillContainer:GetNextSkill()
    if selectSkill then
        if selectSkill:GetID() == 12052 and not self.m_selfActor:CanPerormSecondSkill() then
            return nil, nil
        end

        return selectSkill, SkillCheckResult.New(target, target:GetPosition())
    end

    local IsDazhao = SkillUtil.IsDazhao
    
    local skillCount = skillContainer:GetActiveCount()
    for i = 1, skillCount do
        local skillItem = skillContainer:GetActiveByIdx(i)
        if skillItem then
            if skillItem:GetID() == 12052 and not self.m_selfActor:CanPerormSecondSkill() then
                return nil
            end

            local skillcfg = GetSkillCfgByID(skillItem:GetID())
            if skillcfg then
                if self:InnerCheck(skillItem, skillcfg, includeDazhao, target) then
                    local skillbase = SkillPoolInst:GetSkill(skillcfg, skillItem:GetLevel())
                    if skillbase then 
                        if IsDazhao(skillcfg) then
                            local tmpRet = skillbase:BaseCheck(self.m_selfActor)
                            if tmpRet == SKILL_CHK_RESULT.OK then
                                local ret, skChkRet = self:CheckDazhao(skillbase, skillcfg, target)
                                if ret then
                                    return skillItem, skChkRet
                                end
                            end
                        else
                            local tmpRet, newTarget = skillbase:CheckPerform(self.m_selfActor, target)
                            if tmpRet == SKILL_CHK_RESULT.OK then
                                return skillItem, SkillCheckResult.New(target, target:GetPosition())
                            elseif tmpRet == SKILL_CHK_RESULT.RESELECT then
                                return skillItem, SkillCheckResult.New(newTarget, newTarget:GetPosition())
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

return AIGongSunZan