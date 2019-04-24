local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusFanTan = BaseClass("StatusFanTan", StatusBase)

function StatusFanTan:__init()
    self.m_fantanPercent = 0
end

function StatusFanTan:Init(giver, leftMS, fantanPercent, effect)
    self.m_giver = giver
    self.m_fantanPercent = fantanPercent
    self:SetLeftMS(leftMS)
    self.m_effectMask = effect
end

function StatusFanTan:GetStatusType()
    return StatusEnum.STATUSTYPE_FANTAN
end

function StatusFanTan:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusFanTan:IsPositive()
    return false
end

function StatusFanTan:OnHurt(actor, attackerID, chgVal, hurtType)
    local attacker = ActorManagerInst:GetActor(attackerID)
    if not attacker then
        return
    end
    
    local fantanHurt = FixMul(chgVal, self.m_fantanPercent)
    if fantanHurt < 0 then
        local giver = StatusGiver.New(actor:GetActorID(), 0)
        local delayHurtStatus = StatusFactoryInst:NewStatusDelayHurt(giver, fantanHurt, hurtType, 0, BattleEnum.HPCHGREASON_REBOUND, 1)
        attacker:GetStatusContainer():DelayAdd(delayHurtStatus)
    end
end

return StatusFanTan