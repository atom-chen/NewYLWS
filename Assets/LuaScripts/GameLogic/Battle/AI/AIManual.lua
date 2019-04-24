
local FixMul = FixMath.mul
local AIBase = require "GameLogic.Battle.AI.AIBase"

local SKILL_PERFORM_MODE = SKILL_PERFORM_MODE
local SKILL_CHK_RESULT = SKILL_CHK_RESULT
local BattleEnum = BattleEnum
local CommonDefine = CommonDefine
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local AIManual = BaseClass("AIManual", AIBase)

function AIManual:__init(actor)
end


function AIManual:AI(deltaMS)
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

return AIManual