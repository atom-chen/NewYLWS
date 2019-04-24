local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul


local StatusBase = require("GameLogic.Battle.Status.impl.StatusNTimeBeHurtMul")
local StatusManwangBuff = BaseClass("StatusManwangBuff", StatusBase)

function StatusManwangBuff:__init()
    self.m_otherEffectKey = 0
    self.m_effectKey = 0
end

function StatusManwangBuff:Init(giver, leftMS, beHurtMul, effect)
    StatusBase.Init(self, giver, leftMS, beHurtMul, effect)

    self.m_otherEffectKey = 0
    self.m_effectKey = 0
end

function StatusManwangBuff:GetStatusType()
    return StatusEnum.STATUSTYPE_MANWANGBUFF
end

function StatusManwangBuff:Effect(actor)
    if actor and actor:IsLive() then
        if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
        
        if self.m_otherEffectKey <= 0 then
            self.m_otherEffectKey = self:ShowEffect(actor, 202602)
        end
    end
end


function StatusManwangBuff:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if self.m_otherEffectKey > 0 then
        EffectMgr:RemoveByKey(self.m_otherEffectKey)
        self.m_otherEffectKey = -1
    end
end

return StatusManwangBuff