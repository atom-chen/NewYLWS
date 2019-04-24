local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusYujinMark = BaseClass("StatusYujinMark", StatusBase)

function StatusYujinMark:__init()
    self.m_markCount = 0
    self.m_hurtMul = 1
    self.m_leftMS = 0
end

function StatusYujinMark:Init(giver, leftMS, hurtMul, effect)
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT

    self.m_giver = giver
    self.m_markCount = 0
    self.m_hurtMul = hurtMul or 1
    self.m_leftMS = leftMS
end

function StatusYujinMark:GetStatusType()
    return StatusEnum.STATUSTYPE_YUJINMARK
end

function StatusYujinMark:GetHurtMul()
    return self.m_hurtMul
end

function StatusYujinMark:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusYujinMark:IsPositive()
    return false
end
return StatusYujinMark