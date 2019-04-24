local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusNTimeBeHurtMul = BaseClass("StatusNTimeBeHurtMul", StatusBase)

function StatusNTimeBeHurtMul:__init()
    self.m_giver = false

    self.m_beHurtMul = 0 
    self.m_nTimeBeHurtTypeList = {}
    self.m_effectKey = 0
    self.m_otherEffectKey = 0
    
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT
end

function StatusNTimeBeHurtMul:GetHurtMul()
    return self.m_beHurtMul
end

function StatusNTimeBeHurtMul:IsHurtMulType(hurtType)
    return self.m_nTimeBeHurtTypeList[hurtType]
end

function StatusNTimeBeHurtMul:AddBeHurtMulType(hurtType)
    self.m_nTimeBeHurtTypeList[hurtType] = true
end

function StatusNTimeBeHurtMul:Init(giver, leftMS, beHurtMul, effect)
    self.m_giver = giver
    self.m_beHurtMul = beHurtMul
    self.m_nTimeBeHurtTypeList = {}
    self:SetLeftMS(leftMS) 

    self.m_effectMask = effect
    
    self.m_effectKey = 0
    self.m_otherEffectKey = 0
end

function StatusNTimeBeHurtMul:GetStatusType()
    return StatusEnum.STAUTSTYPE_NEXT_NTIME_BEHURTMUL
end

function StatusNTimeBeHurtMul:Effect(actor)
    if actor and actor:IsLive() then
        if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end 
        if self.m_otherEffectKey <= 0 and self.m_effectMask and self.m_effectMask[2] then
            self.m_otherEffectKey = self:ShowEffect(actor, self.m_effectMask[2])
        end
    end
end

function StatusNTimeBeHurtMul:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
        EffectMgr:RemoveByKey(self.m_otherEffectKey)
        self.m_otherEffectKey = -1
    end
    if actor and actor:IsLive() then  
        if not self.m_effectMask or #self.m_effectMask <= 0 then
            --虚弱状态有默认的受到伤害增加的飘字 
            return
        end
        local positive = self:IsPositive()
        local floatType = 0
        if positive then
            --受到伤害下降
            floatType = ACTOR_ATTR.BE_HURT_END_DOWN
        else
            floatType = ACTOR_ATTR.BE_HURT_END_UP
        end
        actor:ShowFloatHurt(floatType)
    end
end

function StatusNTimeBeHurtMul:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS <= 0 then
        self:ClearEffect(actor)
        return StatusEnum.STATUSCONDITION_END
    end

    return StatusEnum.STATUSCONDITION_CONTINUE
end

function StatusNTimeBeHurtMul:Merge(newStatus, actor)
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    self.m_beHurtMul = FixMul(self.m_beHurtMul, newStatus:GetHurtMul())
end

function StatusNTimeBeHurtMul:IsPositive()
    return self.m_beHurtMul < 1
end

return StatusNTimeBeHurtMul