
local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local table_insert = table.insert
local StatusEnum = StatusEnum

local StatusHP = BaseClass("StatusHP", StatusBase)

-- @judge : ROUNDJUDGE
function StatusHP:__init()    
    self.m_deltaHP = 0
    self.m_hurtType = 0
    self.m_reason = 0
    self.m_judge = 0
    self.m_mergeRule = StatusEnum.MERGERULE_TOGATHER
    self.m_keyFrame = 0
end

function StatusHP:Init(giver, deltaHP, hurtType, reason, judge, keyframe)
    self.m_giver = giver
    self.m_deltaHP = deltaHP
    self.m_hurtType = hurtType
    self.m_reason = reason
    self.m_judge = judge
    self.m_mergeRule = StatusEnum.MERGERULE_TOGATHER
    self.m_keyFrame = keyframe or 0
end

function StatusHP:GetStatusType()
    return StatusEnum.STATUSTYPE_HP
end

-- return : actor isDie
function StatusHP:Effect(actor)
    if not actor then
        return false
    end
    self:EffectHP(self.m_hurtType, self.m_deltaHP, actor, self.m_reason, self.m_judge, self.m_keyFrame)
    if not actor:IsLive() then
        return true
    end
    return false
end

function StatusHP:IsPositive()
    if self.m_deltaHP >= 0 then
        return true
    end
    return false
end

function StatusHP:GetHPChgReason()
    return self.m_reason
end

function StatusHP:GetSkillID()
    return self.m_giver.skillID
end

function StatusHP:GetKeyFrame()
    return self.m_keyFrame
end

function StatusHP:GetHurtType()
    return self.m_hurtType
end

return StatusHP