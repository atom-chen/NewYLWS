local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusLangsheMark = BaseClass("StatusLangsheMark", StatusBase)

local LANGSHE_TIME = 500  -- 技能结束后会清buff

function StatusLangsheMark:__init()
    self.m_markCount = 0
    self.m_startTime = 0
end

function StatusLangsheMark:Init(giver, effect)
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT

    self.m_effectMask = false
    self.m_markCount = 0
    self.m_startTime = 0

    self:SetLeftMS(LANGSHE_TIME)
end

function StatusLangsheMark:GetStatusType()
    return StatusEnum.STATUSTYPE_LANGSHEMARK
end

function StatusLangsheMark:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)

    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    return StatusEnum.STATUSCONDITION_END
end

function StatusLangsheMark:Merge(newStatus, actor)
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    self:SetLeftMS(LANGSHE_TIME)
end

function StatusLangsheMark:GetMarkCount()
    return self.m_markCount
end

function StatusLangsheMark:AddMarkCount()
    self.m_markCount = FixAdd(self.m_markCount, 1)
end

function StatusLangsheMark:ClearMarkData()
    self.m_markCount = 0
    self.m_startTime = 0
    self:SetLeftMS(LANGSHE_TIME)
end

function StatusLangsheMark:SetMarkStartTime(startTime)
    self.m_startTime = startTime
end

function StatusLangsheMark:GetMarkStartTime()
    return self.m_startTime
end

function StatusLangsheMark:IsPositive()
    return false
end
return StatusLangsheMark