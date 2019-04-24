local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local FixSub = FixMath.sub

local StatusSaManbuff = BaseClass("StatusSaManbuff", StatusBase)

function StatusSaManbuff:__init()
    self.m_effectKey = -1
    self.m_suckPercent = 0
    self.m_maxCount = 0
end

function StatusSaManbuff:Init(giver, maxCount, suckPercent, effect)
    self.m_giver = giver
    self.m_effectKey = -1
    self.m_suckPercent = suckPercent
    self.m_effectMask = effect
    self.m_maxCount = maxCount
end

function StatusSaManbuff:GetStatusType()
    return StatusEnum.STATUSTYPE_SAMANBUFF
end

function StatusSaManbuff:GetSuckPercent()
    self.m_maxCount = FixSub(self.m_maxCount, 1)
    return self.m_suckPercent
end

function StatusSaManbuff:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

function StatusSaManbuff:Update(deltaMS, actor)
    if self.m_maxCount > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end


function StatusSaManbuff:Effect(actor)
    if not actor then
        return true
    end

    if self.m_effectMask and #self.m_effectMask > 0 then
        self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
    end

    return false
end

return StatusSaManbuff