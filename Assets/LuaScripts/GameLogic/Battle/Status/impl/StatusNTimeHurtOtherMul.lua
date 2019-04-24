local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusNTimeHurtOtherMul = BaseClass("StatusNTimeHurtOtherMul", StatusBase)   --时间n内，造成伤害调整
 

function StatusNTimeHurtOtherMul:__init()
    self.m_giver = nil
    self.m_hurtMulList = {}
    self.m_effectKey = 0
end

function StatusNTimeHurtOtherMul:Init(giver,leftMS, hurtTypeList, effect)
    self.m_giver = giver 
    self.m_hurtMulList = {}
    self:InitHurtTypeList(hurtTypeList)
    self:SetLeftMS(leftMS)  
    
    if effect then
        self.m_effectMask = effect
    else
        if self:IsPositive() then
            self.m_effectMask = {21018}
        else
            self.m_effectMask = {21017}
        end
    end
    self.m_effectKey = 0
end

function StatusNTimeHurtOtherMul:InitHurtTypeList(hurtTypeList)
    if hurtTypeList then
        for _,v in pairs(hurtTypeList) do
            self.m_hurtMulList[v.hurtType] = {m_hurtPercent = v.hurtPercent}
        end
    end
end

function StatusNTimeHurtOtherMul:GetStatusType()
    return StatusEnum.STAUTSTYPE_NEXT_NTIME_HURTOTHERMUL
end 

function StatusNTimeHurtOtherMul:Effect(actor)
    if actor and actor:IsLive() then  
        if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then 
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end 
    end
end

function StatusNTimeHurtOtherMul:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if actor and actor:IsLive() then  
        local positive = self:IsPositive()
        local floatType = 0
        if positive then 
            floatType = ACTOR_ATTR.HURT_OTHER_END_UP
        else
            floatType = ACTOR_ATTR.HURT_OTHER_END_DOWN
        end 

        actor:ShowFloatHurt(floatType)
    end
end

function StatusNTimeHurtOtherMul:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS <= 0 then 
        self:ClearEffect(actor)
        return StatusEnum.STATUSCONDITION_END
    end
 
    return StatusEnum.STATUSCONDITION_CONTINUE
end 

function StatusNTimeHurtOtherMul:GetHurtOhterMul(hurtType)
    return self.m_hurtMulList[hurtType].m_hurtPercent
end

function StatusNTimeHurtOtherMul:IsHurtMulType(hurtType)
    return self.m_hurtMulList[hurtType]
end 

function StatusNTimeHurtOtherMul:IsPositive()
    local hurtPercent = 0
    if self.m_hurtMulList and #self.m_hurtMulList > 0 then
        for k, v in pairs(self.m_hurtMulList) do
            hurtPercent = v.m_hurtPercent
            break
        end
    end 

    return hurtPercent > 1
end

return StatusNTimeHurtOtherMul