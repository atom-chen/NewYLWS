local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusWenchouMark = BaseClass("StatusWenchouMark", StatusBase)

function StatusWenchouMark:__init()
    self.m_addPercent = 1
    self.m_leftMS = 0
end

function StatusWenchouMark:Init(giver, leftMS, addPercent, effect)
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT

    self.m_giver = giver
    self.m_addPercent = addPercent or 1
    self.m_leftMS = leftMS
end

function StatusWenchouMark:GetStatusType()
    return StatusEnum.STATUSTYPE_WENCHOUMARK
end

function StatusWenchouMark:GetAddPercent()
    return self.m_addPercent
end

function StatusWenchouMark:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusWenchouMark:IsPositive()
    return false
end
return StatusWenchouMark