local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local StatusEnum = StatusEnum

local StatusFactoryInst = StatusFactoryInst
local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2031Hand = BaseClass("Actor2031Hand", Actor)

Actor2031Hand.LIVETIME = 12000

function Actor2031Hand:__init(actorID)
    Actor.__init(self, actorID)

    self.m_liveTime = 0
    self.m_isDead = false

    self.m_handType = 0
end

function Actor2031Hand:LogicUpdate(deltaMS)
    if self.m_isDead then
        return
    end

    self.m_liveTime = FixAdd(self.m_liveTime, deltaMS)
    if self.m_liveTime >= Actor2031Hand.LIVETIME then
        local bossLogic = CtlBattleInst:GetLogic()
        if bossLogic then
            bossLogic:HandDie(self, true)
        end

        self.m_isDead = true
        self:KillSelf(BattleEnum.DEADMODE_NODIESHOW)
        return
    end
end

function Actor2031Hand:CanMove(checkAlive)
    return false
end

function Actor2031Hand:CanBeatBack()
    return false
end

function Actor2031Hand:SetHandType(handType)
    self.m_handType = handType
end

function Actor2031Hand:GetHandType()
    return self.m_handType
end

function Actor2031Hand:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    if deltaHP >= 0 then
        return
    end

    local boss = ActorManagerInst:GetActor(self:GetOwnerID())
    if not boss or not boss:IsLive() then
        return
    end

    boss:DropHP(deltaHP, giver)
end

function Actor2031Hand:OnDie(killerGiver, hpChgReason, killKeyFrame, deadMode)
    self.m_isDead = true

    if killerGiver.actorID ~= self:GetActorID() then
        local bossLogic = CtlBattleInst:GetLogic()
        if bossLogic then
            bossLogic:HandDie(self, false)
        end
        
        local boss = ActorManagerInst:GetActor(self:GetOwnerID())
        if not boss or not boss:IsLive() then
            return
        end

        local com = self:GetComponent()
        if com then
            com:ObjectExploded()
        else
            -- Logger.Log('2031Hand die no component')
        end
    else
        deadMode = BattleEnum.DEADMODE_NODIESHOW
    end

    Actor.OnDie(self, killerGiver, hpChgReason, killKeyFrame, deadMode)
end

function Actor2031Hand:HasHurtAnim()
    return false
end

function Actor2031Hand:OnSBDie(dieActor, killerGiver)
    if dieActor:GetActorID() == self:GetOwnerID() then
        self:KillSelf(BattleEnum.DEADMODE_NODIESHOW)
        self.m_isDead = true
    end
end

function Actor2031Hand:OnBorn(create_param)    
    Actor.OnBorn(self, create_param)
    self.m_liveTime = 0

    local giver = StatusGiver.New(self.m_actorID, 0)
    local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, 999999) 
    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_HURTBACK)
    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_HURTFLY)
    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_PHY_HURT)
    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_INTERRUPT)
    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_STUN)

    immuneBuff:SetCanClearByOther(false)
    self.m_statusContainer:Add(immuneBuff)
end

return Actor2031Hand