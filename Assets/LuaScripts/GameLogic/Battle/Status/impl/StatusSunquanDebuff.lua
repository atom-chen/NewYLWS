local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add


local StatusNTimeBeHurtMul = require("GameLogic.Battle.Status.impl.StatusNTimeBeHurtMul")
local StatusSunquanDebuff = BaseClass("StatusSunquanDebuff", StatusNTimeBeHurtMul)

function StatusSunquanDebuff:__init()
    self.m_hurt = 0
    self.m_intervalTime = 0
end


-- function StatusSunquanDebuff:Init(giver, leftMS, beHurtMul, effect)
--     StatusNTimeBeHurtMul.Init(self, giver, leftMS, beHurtMul, effect)
-- end

function StatusSunquanDebuff:SetHurt(hurt)
    self.m_hurt = hurt
end

function StatusSunquanDebuff:GetStatusType()
    return StatusEnum.STATUSTYPE_SUNQUANDEBUFF
end


function StatusSunquanDebuff:Update(deltaMS, actor)
    self.m_intervalTime = FixSub(self.m_intervalTime, deltaMS)
    if self.m_intervalTime <= 0 then
        self.m_intervalTime = FixAdd(self.m_intervalTime, 1000)

        if actor and actor:IsLive() then
            local status = StatusFactoryInst:NewStatusDelayHurt(self.m_giver, self.m_hurt, BattleEnum.HURTTYPE_MAGIC_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0)
            actor:GetStatusContainer():DelayAdd(status)
        end
    end

    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS <= 0 then
        self:ClearEffect(actor)
        return StatusEnum.STATUSCONDITION_END
    end

    return StatusEnum.STATUSCONDITION_CONTINUE
end

function StatusSunquanDebuff:ClearEffect(actor)
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
        if #self.m_nTimeBeHurtTypeList > 0 then
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
end

function StatusSunquanDebuff:IsPositive()
    return false
end

return StatusSunquanDebuff