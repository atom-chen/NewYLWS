local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusQingLongMark = BaseClass("StatusQingLongMark", StatusBase)

function StatusQingLongMark:__init()

    self.m_targetID = 0
end

function StatusQingLongMark:Init(giver, leftMS, targetID, effect)
    self.m_giver = giver
    self:SetLeftMS(leftMS)
    self.m_targetID = targetID
    self.m_effectMask = effect
end

function StatusQingLongMark:GetStatusType()
    return StatusEnum.STATUSTYPE_QINGLONGMARK
end

function StatusQingLongMark:GetMarkTargetID()
    return self.m_targetID
end

function StatusQingLongMark:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusQingLongMark:IsPositive()
    return false
end

return StatusQingLongMark