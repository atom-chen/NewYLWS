local ConfigUtil = ConfigUtil
local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local FixSub = FixMath.sub
local SkillPoolInst = SkillPoolInst
local SkillCheckResult = SkillCheckResult


local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIYujin = BaseClass("AIYujin", AIManual)


function AIYujin:__init(actor)
    self.m_passiveTime = 0 

    self.m_10613skillItem = self.m_selfActor:GetSkillContainer():GetActiveByID(10613)
    self.m_performed10613 = false
end

function AIYujin:__delete()
    self.m_passiveTime = 0 

    self.m_10613skillItem = nil
    self.m_performed10613 = false
end

function AIYujin:AI(deltaMS)
    if not self:CheckSpecialState(deltaMS) then
        return
    end

    if not self:CanAI() then
        return
    end

    if self.m_selfActor:ShouldPerform10613() and self.m_10613skillItem then
        self.m_selfActor:ResetPerform10613()
        self:PerformSkill(self.m_selfActor, self.m_10613skillItem, self.m_selfActor:GetPosition(), SKILL_PERFORM_MODE.AI)
        return
    end

    local currState = self.m_selfActor:GetCurrStateID()
    if currState == BattleEnum.ActorState_IDLE or currState == BattleEnum.ActorState_MOVE then  
        if self.m_currTargetActorID == 0 then
            local tmpTarget = self:FindTarget()
            if not tmpTarget then
                self:OnNoTarget()
            else
                self:SetTarget(tmpTarget:GetActorID())
            end
        end

        if self.m_currTargetActorID ~= 0 then
            local target = ActorManagerInst:GetActor(self.m_currTargetActorID)
            if not target or not target:IsLive() then
                self:SetTarget(0)
                return
            end

            local selfProf = self.m_selfActor:GetProf()
            if selfProf == CommonDefine.PROF_1 or selfProf == CommonDefine.PROF_3 then
                if target:GetProf() == CommonDefine.PROF_2 then
                    local profTarget = CtlBattleInst:GetLogic():GetNearestProfTarget(self.m_selfActor)
                    if profTarget then
                        self:SetTarget(profTarget:GetActorID())
                        target = profTarget

                    end
                end
            end

            local p = target:GetPosition()
            local selectSkill, chkRet = self:SelectSkill(target, self:AutoSelectDazhao())

            if selectSkill and chkRet then
                if chkRet.newTarget then
                    self:SetTarget(chkRet.newTarget:GetActorID())
                    target = chkRet.newTarget
                end
                p = chkRet.pos
            end
            
            local normalRet = SKILL_CHK_RESULT.ERR
            if not selectSkill then
                normalRet, selectSkill = self:SelectNormalSkill(target)
            end

            if selectSkill then
                self:PerformSkill(target, selectSkill, p, SKILL_PERFORM_MODE.AI)
            else
                if normalRet == SKILL_CHK_RESULT.TARGET_TYPE_UNFIT then
                    self:SetTarget(0)
                end

                if self:ShouldFollowEnemy(normalRet) then
                    
                    self:Follow(target, deltaMS)
                elseif self:ShouldBackAway(target) then
                    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_selfActor:GetWujiangID())
                    self:BackAway(target, wujiangCfg.backaway_dis)                
                else
                    self:TryStop(target:GetPosition())
                end
            end
        end
    end
end


function AIYujin:SelectSkill(target, includeDazhao)
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
        if skillID == 10613 then
            return
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

return AIYujin