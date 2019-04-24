local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusDiaoChanMark = BaseClass("StatusDiaoChanMark", StatusBase)

function StatusDiaoChanMark:__init()
    self.m_markCount = 0
end

function StatusDiaoChanMark:Init(giver, effect)
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT

    self.m_giver = giver
    self.m_markCount = 0
end

function StatusDiaoChanMark:GetStatusType()
    return StatusEnum.STATUSTYPE_DIAOCHANMARK
end

function StatusDiaoChanMark:Update(deltaMS, actor)
    if self.m_markCount > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    -- self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusDiaoChanMark:GetMarkCount()
    return self.m_markCount
end

function StatusDiaoChanMark:AddMarkCount(count)
    self.m_markCount = FixAdd(self.m_markCount, count)
end

function StatusDiaoChanMark:SetMarkCount(count)
    self.m_markCount = count
end

function StatusDiaoChanMark:IsPositive()
    return false
end
return StatusDiaoChanMark