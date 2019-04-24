local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub

local StatusWudi = BaseClass("StatusWudi", StatusBase)

function StatusWudi:__init()
    self.m_leftTime = 0
    self.m_effectKey = -1
    self.m_giver = false
end

function StatusWudi:Init(giver, leftTime, effect)
    self.m_giver = giver
    self.m_leftTime = leftTime
    self.m_effectMask = effect
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT
    self.m_effectKey = -1
end

function StatusWudi:GetStatusType()
    return StatusEnum.STATUSTYPE_WUDI
end

function StatusWudi:Effect(actor)
    if actor then
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end
    return false
end

function StatusWudi:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

function StatusWudi:Update(deltaMS, actor)
    self.m_leftTime = FixSub(self.m_leftTime, deltaMS)

    if self.m_leftTime > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

return StatusWudi