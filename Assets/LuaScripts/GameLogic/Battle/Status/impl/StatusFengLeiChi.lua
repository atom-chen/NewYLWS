local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local StatusFactoryInst = StatusFactoryInst

local StatusFengLeiChi = BaseClass("StatusFengLeiChi", StatusBase)

function StatusFengLeiChi:__init()
    self.m_effectKey = -1

    self.m_chgAtkSpeedPercent = 0
    self.m_chgBaojiPercent = 0
    self.m_hurtOhterRadius = 0
    self.m_hurtOtherPercent = 0
    self.m_selfHurtPercent = 0

    self.m_chgAtkSpeed = 0
    self.m_chgBaoji = 0
end

function StatusFengLeiChi:Init(giver, leftMS, atkSpeedPercent, baojiPercent, radius, otherHurtPercent, selfHurtPercent, effect)
    self.m_giver = giver
    self.m_effectMask = effect
    self:SetLeftMS(leftMS)
    self.m_effectKey = -1

    self.m_chgAtkSpeedPercent = atkSpeedPercent
    self.m_chgBaojiPercent = baojiPercent
    self.m_hurtOhterRadius = radius
    self.m_hurtOtherPercent = otherHurtPercent
    self.m_selfHurtPercent = selfHurtPercent

    self.m_chgAtkSpeed = 0
    self.m_chgBaoji = 0
end


function StatusFengLeiChi:GetStatusType()
    return StatusEnum.STATUSTYPE_FENGLEICHI
end

function StatusFengLeiChi:GetRadius()
    return self.m_hurtOhterRadius
end

function StatusFengLeiChi:GetHurtPercent()
    return self.m_hurtOtherPercent
end

function StatusFengLeiChi:Effect(actor)
    if actor and actor:IsLive() then 
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end

    return false
end

function StatusFengLeiChi:AddAttrBuff(actor)
    if self.m_chgAtkSpeedPercent > 0 then
        local chgAtkSpeed = actor:CalcAttrChgValue(ACTOR_ATTR.BASE_ATKSPEED, self.m_chgAtkSpeedPercent)
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
        self.m_chgAtkSpeed = FixAdd(self.m_chgAtkSpeed, chgAtkSpeed)
    end

    if self.m_chgBaojiPercent > 0 then
        local chgBaoji = actor:CalcAttrChgValue(ACTOR_ATTR.BASE_MAGIC_BAOJI, self.m_chgBaojiPercent)
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_BAOJI, chgBaoji)
        self.m_chgBaoji = FixAdd(self.m_chgBaoji, chgBaoji)
    end

end

function StatusFengLeiChi:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if not actor or not actor:IsLive() then
        return
    end

    local actorData = actor:GetData()
    if self.m_chgAtkSpeed > 0 then
        actorData:AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, FixMul(self.m_chgAtkSpeed, -1))
        self.m_chgAtkSpeed = 0
    end

    if self.m_chgBaoji > 0 then
        actorData:AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_BAOJI, FixMul(self.m_chgBaoji, -1))
        self.m_chgBaoji = 0
    end

    local curHP = actorData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local selfHurtHP = FixIntMul(curHP, self.m_selfHurtPercent)
    local status = StatusFactoryInst:NewStatusDelayHurt(self.m_giver, FixMul(-1, selfHurtHP), BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_SELF_HURT, 0, BattleEnum.ROUNDJUDGE_NORMAL)
    actor:GetStatusContainer():Add(status, actor)

    self.m_chgAtkSpeedPercent = 0
    self.m_chgBaojiPercent = 0
    self.m_hurtOhterRadius = 0
    self.m_hurtOtherPercent = 0
    self.m_selfHurtPercent = 0
end

function StatusFengLeiChi:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end


return StatusFengLeiChi