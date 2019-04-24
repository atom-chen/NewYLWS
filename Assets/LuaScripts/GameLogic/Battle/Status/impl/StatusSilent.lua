local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub

local StatusSilent = BaseClass("StatusSilent", StatusBase)

-- 魔法沉默
function StatusSilent:__init()
    self.m_effectKey = -1
end

function StatusSilent:Init(giver, leftMS, effect)
    self.m_giver = giver
    if effect then
        self.m_effectMask = effect
    else
        self.m_effectMask = {20024}
    end
    self.m_mergeRule = StatusEnum.MERGERULE_LONGER_LEFT
    self:SetLeftMS(leftMS)
    self.m_effectKey = -1
end

function StatusSilent:GetStatusType()
    return StatusEnum.STATUSTYPE_SILENT
end

function StatusSilent:Effect(actor)
    if actor then
        actor:MagicSilent()

        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end

    return false
end

function StatusSilent:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

function StatusSilent:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

function StatusSilent:IsPositive()
    return false
end

return StatusSilent