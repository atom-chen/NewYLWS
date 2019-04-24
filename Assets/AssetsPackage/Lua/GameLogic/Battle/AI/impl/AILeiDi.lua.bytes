local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AILeiDi = BaseClass("AILeiDi", AIManual)

function AILeiDi:AI(deltaMS)
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

            local normalRet = SKILL_CHK_RESULT.ERR
            if not selectSkill then
                normalRet, selectSkill = self:SelectNormalSkill(target)
            end

            if selectSkill then
                self:PerformSkill(target, selectSkill, p, SKILL_PERFORM_MODE.AI)
            end
        end
    end
end



return AILeiDi