local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub

local StatusChaoFeng = BaseClass("StatusChaoFeng", StatusBase)

function StatusChaoFeng:__init()
    self.m_targetID = 0
    self.m_effectKey = -1
end

function StatusChaoFeng:Init(giver, targetID, leftMS)
    self.m_giver = giver
    self.m_targetID = targetID
    self.m_effectMask = {20014}
    self.m_effectKey = -1
    self:SetLeftMS(leftMS)
end

function StatusChaoFeng:GetStatusType()
    return StatusEnum.STATUSTYPE_CHAOFENG
end

function StatusChaoFeng:Effect(actor)
    if not actor then
        return false
    end
    actor:SetTargetID(self.m_targetID)

    if self.m_effectMask and #self.m_effectMask > 0 then
        self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
    end
    return false
end

function StatusChaoFeng:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

function StatusChaoFeng:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE,false
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusChaoFeng:GetTargetID()
    return self.m_targetID
end

function StatusChaoFeng:IsPositive()
    return false
end
return StatusChaoFeng
