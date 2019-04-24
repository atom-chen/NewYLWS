local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusZhangfeiDef = BaseClass("StatusZhangfeiDef", StatusBase)


function StatusZhangfeiDef:__init()
    self.m_giver = false

    self.m_hurtDefPercent = 0
    self.m_leftMS = 0
    self.m_defTargetList = {}

    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT
end

function StatusZhangfeiDef:GetDefPercent()
    return self.m_hurtDefPercent
end

function StatusZhangfeiDef:IsDefHurt(targetID)
    return self.m_defTargetList[targetID]
end

function StatusZhangfeiDef:AddDefTargetID(targetID)
    self.m_defTargetList[targetID] = true
end

function StatusZhangfeiDef:Init(giver, leftMS, hurtDefPercent, effect)
    self.m_giver = giver
    self.m_hurtDefPercent = hurtDefPercent
    self.m_defTargetList = {}
    self:SetLeftMS(leftMS)
end

function StatusZhangfeiDef:GetStatusType()
    return StatusEnum.STATUSTYPE_ZHANGFEIDEF
end

function StatusZhangfeiDef:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS <= 0 then
        return StatusEnum.STATUSCONDITION_END
    end

    return StatusEnum.STATUSCONDITION_CONTINUE
end

function StatusZhangfeiDef:IsPositive()
    return false
end
return StatusZhangfeiDef