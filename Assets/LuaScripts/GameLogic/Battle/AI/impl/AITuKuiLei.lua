local ConfigUtil = ConfigUtil
local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AITuKuiLei = BaseClass("AITuKuiLei", AIManual)

function AITuKuiLei:__init(actor)
    self.m_shouldPerform20461Skill = false
    self.m_perform20461SkillPos = 0
end

function AITuKuiLei:__delete()
    self.m_shouldPerform20461Skill = false 
    self.m_perform20461SkillPos = 0
end

function AITuKuiLei:Attack(targetID)
    self.m_currTargetActorID = targetID
end

function AITuKuiLei:AI(deltaMS)
    if not self:CheckSpecialState(deltaMS) then
        return
    end

    if not self:CanAI() then
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
            if self.m_shouldPerform20461Skill then
                local skillItem = self.m_selfActor:GetSkillContainer():GetByID(20461)
                if not skillItem then
                    local newPos = FixNewVector3(self.m_selfActor:GetPosition().x, self.m_selfActor:GetOrignalY(), self.m_selfActor:GetPosition().z)
                    self.m_selfActor:SetPosition(newPos)
                    self.m_shouldPerform20461Skill = false
                    return
                end

                local target = ActorManagerInst:GetActor(self.m_currTargetActorID)
                self:PerformSkill(target, skillItem, self.m_perform20461SkillPos, SKILL_PERFORM_MODE.AI)

                self.m_shouldPerform20461Skill = false

            else
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
                local selectSkill = nil
                local normalRet = SKILL_CHK_RESULT.ERR
                normalRet, selectSkill = self:SelectNormalSkill(target)

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
end

function AITuKuiLei:Perform20461Skill(performPos, targetID)
    self.m_shouldPerform20461Skill = true
    self.m_currTargetActorID = targetID
    self.m_perform20461SkillPos = performPos
end

return AITuKuiLei