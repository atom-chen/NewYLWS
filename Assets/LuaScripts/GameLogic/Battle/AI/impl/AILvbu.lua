local ConfigUtil = ConfigUtil
local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local FixSub = FixMath.sub
local FixMul = FixMath.mul

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AILvbu = BaseClass("AILvbu", AIManual)


function AILvbu:__init(actor)
    self.m_10423skillItem = self.m_selfActor:GetSkillContainer():GetPassiveByID(10423)
    self.m_performed10423 = false
end

function AILvbu:__delete()
    self.m_10423skillItem = nil
    self.m_performed10423 = false
end

function AILvbu:AI(deltaMS)
    if not self:CheckSpecialState(deltaMS) then
        return
    end

    if not self:CanAI() then
        return
    end

    local currState = self.m_selfActor:GetCurrStateID()
    if currState == BattleEnum.ActorState_IDLE or currState == BattleEnum.ActorState_MOVE then    
        if self.m_performed10423 then
            local target, isFollow = self:GetNearestTarget()
            if target and target:IsLive() then
                local skillcfg = ConfigUtil.GetSkillCfgByID(self.m_10423skillItem:GetID())
                if isFollow then
                    self:Follow(target, deltaMS)
                else
                    self:PerformSkill(self.m_selfActor, self.m_10423skillItem, self.m_selfActor:GetPosition(), SKILL_PERFORM_MODE.AI)
                    self.m_performed10423 = false
                end
            else
                self.m_performed10423 = false
            end

            return
        end

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

function AILvbu:EffectPassiveSkill()
    self.m_performed10423 = true
end

function AILvbu:GetNearestTarget()
    local minDis = 9999
    local radius = self.m_selfActor:GetPassiveB()
    radius = FixMul(radius, radius)
    local isFollow = false
    local target = false
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(self.m_selfActor, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local dir = tmpTarget:GetPosition() - self.m_selfActor:GetPosition()
            dir.y = 0

            local distance2 = dir:SqrMagnitude()
            if distance2 < minDis then
                target = tmpTarget
                minDis = distance2
                if distance2 > radius then
                    isFollow = true
                else
                    isFollow = false
                end
            end
        end
    )

    return target, isFollow
end

return AILvbu