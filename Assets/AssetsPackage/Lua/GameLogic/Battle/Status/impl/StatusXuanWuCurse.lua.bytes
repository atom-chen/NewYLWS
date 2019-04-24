local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusXuanWuCurse = BaseClass("StatusXuanWuCurse", StatusBase)

function StatusXuanWuCurse:__init()

    self.m_targetID = 0
end

function StatusXuanWuCurse:Init(giver, leftMS, targetID, effect)
    self.m_giver = giver
    self:SetLeftMS(leftMS)
    self.m_targetID = targetID
end

function StatusXuanWuCurse:GetStatusType()
    return StatusEnum.STATUSTYPE_XUANWUCURSE
end

function StatusXuanWuCurse:GetCurseTargetID()
    return self.m_targetID
end

function StatusXuanWuCurse:GetLeftTime()
    return self.m_leftMS
end

function StatusXuanWuCurse:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusXuanWuCurse:IsPositive()
    return false
end

return StatusXuanWuCurse