local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusGongsunzanMark = BaseClass("StatusGongsunzanMark", StatusBase)

function StatusGongsunzanMark:__init()
    self.m_stunTime = 0
    self.m_leftMS = 0
end

function StatusGongsunzanMark:Init(giver, leftMS, stunTime, effect)
    self.m_mergeRule = StatusEnum.MERGERULE_MERGE

    self.m_giver = giver
    self:SetLeftMS(leftMS)
    self.m_stunTime = stunTime
end

function StatusGongsunzanMark:GetStatusType()
    return StatusEnum.STATUSTYPE_GONGSUNZANMARK
end

function StatusGongsunzanMark:GetStunTime()
    return self.m_stunTime
end

function StatusGongsunzanMark:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusGongsunzanMark:IsPositive()
    return false
end

function StatusGongsunzanMark:Merge(newStatus, actor)
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_leftMS = self.m_totalMS
end

return StatusGongsunzanMark