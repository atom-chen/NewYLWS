local ConfigUtil = ConfigUtil
local FixDiv = FixMath.div
local SkillPoolInst = SkillPoolInst
local ACTOR_ATTR = ACTOR_ATTR
local SkillCheckResult = SkillCheckResult


local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIWenchou = BaseClass("AIWenchou", AIManual)


function AIWenchou:SelectSkill(target, includeDazhao)
    if not target then return nil end
    if includeDazhao == nil then includeDazhao = true end

    if not self.m_selfActor:GetStatusContainer():CanAnySkill() then
        return nil
    end

    local skillContainer = self.m_selfActor:GetSkillContainer()
    local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID

    local selectSkill = skillContainer:GetNextSkill()
    if selectSkill then
        return selectSkill, SkillCheckResult.New(target, target:GetPosition())
    end

    local IsDazhao = SkillUtil.IsDazhao
    
    local skillCount = skillContainer:GetActiveCount()
    for i = 1, skillCount do
        local skillItem = skillContainer:GetActiveByIdx(i)
        local skillID = skillItem:GetID()
        if skillID == 10763 and not self:CheckHP() then
            return nil
        end

        if skillItem then
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

function AIWenchou:CheckHP()
    local curHp = self.m_selfActor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local baseHp = self.m_selfActor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local xPercent = self.m_selfActor:Get10763X()

    return FixDiv(curHp, baseHp) < xPercent
end

return AIWenchou