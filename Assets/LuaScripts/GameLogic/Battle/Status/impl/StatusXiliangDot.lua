local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusXiliangDot = BaseClass("StatusXiliangDot", StatusBase)

function StatusXiliangDot:__init()
    self.m_hpChgPercent = 0
    self.m_isControlSkill = false
    self.m_key = false
    self.m_effectMask = false
end

function StatusXiliangDot:Init(giver, leftMS, hpChgPercent)
    self.m_hpChgPercent = hpChgPercent
    self.m_mergeRule = StatusEnum.MERGERULE_TOGATHER
    self.m_isControlSkill = false
    self.m_key = false
    self.m_effectMask = false
    self:SetLeftMS(leftMS)
end

function StatusXiliangDot:GetStatusType()
    return StatusEnum.STATUSTYPE_XILIANGDOT
end

function StatusXiliangDot:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusXiliangDot:GetHPChgPercent()
    return self.m_hpChgPercent or 0
end

function StatusXiliangDot:IsPositive()
    return false
end

return StatusXiliangDot