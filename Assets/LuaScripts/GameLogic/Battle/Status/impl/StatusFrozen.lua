local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local FixSub = FixMath.sub

local StatusFrozen = BaseClass("StatusFrozen", StatusBase)

function StatusFrozen:__init()
    self.m_effectKey = -1
    self.m_colorKey = -1
end

function StatusFrozen:Init(giver, leftMS, effect)
    self.m_giver = giver
    self.m_mergeRule = StatusEnum.MERGERULE_LONGER_LEFT
    self:SetLeftMS(leftMS)
    self.m_effectKey = -1
    self.m_colorKey = -1

    if effect then
        self.m_effectMask = effect
    else
        self.m_effectMask = { 30002 }
    end
end

function StatusFrozen:GetStatusType()
    return StatusEnum.STATUSTYPE_FROZEN
end

function StatusFrozen:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if not actor then
        return
    end

    actor:Idle(BattleEnum.IdleType_STAND, false, false, BattleEnum.IdleReason_NORMAL)
    actor:FreezeDone()
end

function StatusFrozen:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

function StatusFrozen:IsPositive()
    return false
end

function StatusFrozen:Effect(actor)
    if not actor then
        return true
    end

    actor:Frozen()

     -- TODO Show effect and color
    if self.m_effectMask and #self.m_effectMask > 0 then
        self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
    end

    return false
end

return StatusFrozen