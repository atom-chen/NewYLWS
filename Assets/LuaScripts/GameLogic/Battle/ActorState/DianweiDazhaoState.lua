local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FrameDebuggerInst = FrameDebuggerInst

local DazhaoState = require "GameLogic.Battle.ActorState.DazhaoState"
local DianweiDazhaoState = BaseClass("DianweiDazhaoState", DazhaoState)
local SAnimationState = require "GameLogic.Battle.Animator.SAnimator"


function DianweiDazhaoState:CheckKeyFrame()
    if self.m_currPhase == DazhaoState.PHASE_PREPARE then
        if CtlBattleInst:GetPauserID() == self.m_selfActor:GetActorID() then
            self:OnPrepareEnd()
        end
    else
        if not self.m_skillBase then
            Logger.LogError('no skillbase ' .. self.m_selfActor:GetActorID() .. ',' .. self.m_skillItem:GetID())
            return
        end

        self.m_keyFrames = FixAdd(self.m_keyFrames, 1)

        if self.m_keyFrames == 3 then
            if self.m_skillBase:GetLevel() <= 1 then
                self.m_selfActor:GotoIdle()
                return
            end
        end

        if self.m_keyFrames == 4 then
            self.m_selfActor:PlayAnim(BattleEnum.ANIM_DIANWEIDAZHAO2)
        end

        local targetActor = ActorManagerInst:GetActor(self.m_targetID)
        FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_SKILL, self.m_selfActor:GetCamp(), self.m_skillItem:GetID(), self.m_selfActor:GetActorID(), self.m_targetID, self.m_keyFrames)
        self.m_skillBase:Perform(self.m_selfActor, targetActor, self.m_targetPos, PerformParam.New(self.m_keyFrames, self.m_preParam, self.m_performMode))
        -- self:ChangeActorColor(SKILL_PHASE.KEY_FRAME)
    end
end


function DianweiDazhaoState:LogicUpdate(deltaMS)
    if self.m_selfActor:IsFightEnd() and self.m_keyFrames < 4 then
        self.m_selfActor:GotoIdle()
    end
end

return DianweiDazhaoState