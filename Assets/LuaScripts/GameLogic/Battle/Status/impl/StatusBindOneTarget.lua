local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add 
local FixMul = FixMath.mul
local FixFloor = FixMath.floor

local StatusBindOneTarget = BaseClass("StatusBindOneTarget", StatusBase)

function StatusBindOneTarget:__init()
    self.m_effectKey = -1

    self.m_actorID = {}
    self.m_hurtPercenet = 0
    self.m_otherHurt = 0
end

function StatusBindOneTarget:Init(giver, leftMS, hurtPercent, effect)
    self.m_giver = giver
    self.m_effectMask = effect
    self:SetLeftMS(leftMS)
    self.m_effectKey = -1

    self.m_otherHurt = 0
    self.m_actorID = 0
    self.m_hurtPercenet = hurtPercent
end

function StatusBindOneTarget:SetTargetID(targetID)
    self.m_actorID = targetID
end

function StatusBindOneTarget:GetStatusType()
    return StatusEnum.STATUSTYPE_BINDONETARGET
end

function StatusBindOneTarget:ReplayceHurt(hurt, reason)
    if hurt >= 0 then
        return hurt
    end

    if reason == BattleEnum.HPCHGREASON_BIND then
        return hurt
    end

    local target = ActorManagerInst:GetActor(self.m_actorID)
    if target and target:IsLive() then
        self.m_otherHurt = FixMul(self.m_hurtPercenet, hurt)
        self.m_otherHurt = FixFloor(self.m_otherHurt)
        hurt = FixSub(hurt, self.m_otherHurt)
    end

    return FixFloor(hurt)
end


function StatusBindOneTarget:OnHurt(actor, chgVal, hpChgreason, giver, hurtType)
    if chgVal >= 0 or not actor or not actor:IsLive() then
        return
    end

    if hpChgreason == BattleEnum.HPCHGREASON_BIND then
        return
    end

    local actorID = actor:GetActorID()
    local target = ActorManagerInst:GetActor(self.m_actorID)
    if target and target:IsLive() then
        local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, self.m_otherHurt, hurtType, 10, BattleEnum.HPCHGREASON_BIND, 1)
        target:GetStatusContainer():DelayAdd(statusHP)
    end
end

function StatusBindOneTarget:Effect(actor)
    if actor then 
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end

    return false
end

function StatusBindOneTarget:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    self.m_otherHurt = 0
    self.m_actorID = 0
    self.m_hurtPercenet = 0
end

function StatusBindOneTarget:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

function StatusBindOneTarget:Merge(newStatus, actor) 
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_leftMS = self.m_totalMS
end


return StatusBindOneTarget