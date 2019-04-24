
local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub

local StatusYuanshuShihunCurse = BaseClass("StatusYuanshuShihunCurse", StatusBase)

function StatusYuanshuShihunCurse:__init()
    self.m_effectKey = -1
    self.m_leftMS = 0
end

function StatusYuanshuShihunCurse:Init(giver, leftMS, effect)
    self.m_effectKey = -1
    self.m_leftMS = leftMS
end

function StatusYuanshuShihunCurse:GetStatusType()
    return StatusEnum.STATUSTYPE_YUANSHUSHIHUNCURSE
end

function StatusYuanshuShihunCurse:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusYuanshuShihunCurse:IsPositive()
    return false
end

return StatusYuanshuShihunCurse
