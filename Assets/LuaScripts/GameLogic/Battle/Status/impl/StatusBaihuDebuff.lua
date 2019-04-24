
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusBaihuDebuff = BaseClass("StatusBaihuDebuff", StatusBase)

function StatusBaihuDebuff:__init()
    self.m_leftMS = 0
    self.m_reducePercent = 0
end

function StatusBaihuDebuff:Init(giver, leftMS, reducePercent)
    self.m_giver = giver
    self.m_leftMS = leftMS
    self.m_reducePercent = reducePercent
    self:SetLeftMS(leftMS)
end

function StatusBaihuDebuff:GetReducePercent()
    return self.m_reducePercent
end

function StatusBaihuDebuff:AddReducePercent(percent)
    self.m_reducePercent = FixAdd(self.m_reducePercent, percent)
end

function StatusBaihuDebuff:GetStatusType()
    return StatusEnum.STATUSTYPE_BAIHU_DEBUFF
end

function StatusBaihuDebuff:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)

    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusBaihuDebuff:IsPositive()
    return false
end

return StatusBaihuDebuff 