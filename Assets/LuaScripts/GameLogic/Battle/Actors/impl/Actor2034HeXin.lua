local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixAdd = FixMath.add
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local StatusEnum = StatusEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2034HeXin = BaseClass("Actor2034HeXin", Actor)

function Actor2034HeXin:__init(actorID)
    self.m_isDead = false
    self.m_lifeTime = 0
end

function Actor2034HeXin:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local giver = StatusGiver.New(self:GetActorID(), 0)
    local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, 999999) 
    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
    immuneBuff:SetCanClearByOther(false)
    self:GetStatusContainer():Add(immuneBuff, self)

    self.m_lifeTime = 0
end

function Actor2034HeXin:HasHurtAnim()
    return false
end

function Actor2034HeXin:LogicUpdate(deltaMS)
    if self.m_isDead then
        return
    end

    self.m_lifeTime = FixAdd(self.m_lifeTime, deltaMS)
    if self.m_lifeTime >= 8500 then
        self.m_isDead = true
        self:KillSelf()
        return
    end
    
    local owner = ActorManagerInst:GetActor(self.m_ownerID)
    if not owner or not owner:IsLive() then
        self.m_isDead = true
        self:KillSelf()
    end
end

function Actor2034HeXin:NeedBlood()
    return false
end

function Actor2034HeXin:CanMove(checkAlive)
    return false
end

function Actor2034HeXin:CanBeatBack()
    return false
end

function Actor2034HeXin:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    if deltaHP >= 0 then
        return
    end

    

    local owner = ActorManagerInst:GetActor(self.m_ownerID)
    if not owner or not owner:IsLive() then
        return
    end

    owner:DropHP(deltaHP)
end

function Actor2034HeXin:OnDie(killerGiver, hpChgReason, killKeyFrame, deadMode)
    self.m_isDead = true
    deadMode = BattleEnum.DEADMODE_NODIESHOW
    Actor.OnDie(self, killerGiver, hpChgReason, killKeyFrame, deadMode)
end

return Actor2034HeXin