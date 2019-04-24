local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local ActorManagerInst = ActorManagerInst

local StatusDelayHurt = BaseClass("StatusDelayHurt", StatusBase)

function StatusDelayHurt:__init()
    self.m_deltaHP = 0
    self.m_hurtType = BattleEnum.HURTTYPE_REAL_HURT
    self.m_intervalTime = 0
    self.m_delayS = 0
    self.m_reason = false
    self.m_hurtFrame = 0
    self.m_judge = BattleEnum.ROUNDJUDGE_NORMAL
end

function StatusDelayHurt:Init(giver, deltaHP, hurtType, delayS, reason, hurtFrame, judge)
    self.m_giver = giver
    self.m_intervalTime = 0
    self.m_deltaHP = deltaHP
    self.m_hurtType = hurtType
    self.m_delayS = delayS
    self.m_reason = reason
    self.m_hurtFrame = hurtFrame    
    self.m_mergeRule = StatusEnum.MERGERULE_TOGATHER
    self.m_judge = judge or BattleEnum.ROUNDJUDGE_NORMAL
end

function StatusDelayHurt:GetStatusType()
    return StatusEnum.STATUSTYPE_DELAY_HURT
end

function StatusDelayHurt:Update(deltaMS, actor)
    local perfomer = ActorManagerInst:GetActor(self.m_giver.actorID)
    if not perfomer or not perfomer:IsLive() then
        return StatusEnum.STATUSCONDITION_END
    end

    self.m_intervalTime = FixAdd(self.m_intervalTime, deltaMS)

    if self.m_intervalTime < self.m_delayS then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    self:EffectHP(self.m_hurtType, self.m_deltaHP, actor, self.m_reason, self.m_judge, self.m_hurtFrame)
    local isDie = false
    if not actor:IsLive() then
        isDie = true
    end
    return StatusEnum.STATUSCONDITION_END, isDie
end

function StatusDelayHurt:IsPositive()
    return false
end

return StatusDelayHurt