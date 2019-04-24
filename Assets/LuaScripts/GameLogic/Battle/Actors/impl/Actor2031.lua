local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local StatusEnum = StatusEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2031 = BaseClass("Actor2031", Actor)

function Actor2031:__init(actorID)
    Actor.__init(self, actorID)
    self.m_leftHand = false
    self.m_rightHand = false
    
    self.m_handID = 0
    self.m_rightHandID = 0

    self.m_leftHandDead = false
    self.m_rightHandDead = false

    self.m_isLeftHandShow = true
    self.m_isRightHandShow = true

    self.m_handDropHP = 0
    self.m_handDropHpGiver = nil
end

function Actor2031:GetHandID()
    return self.m_handID
end

function Actor2031:SetHandID(handID)
    self.m_handID = handID
end

function Actor2031:CanBeatBack()
    return false
end


function Actor2031:LeftHandDie()
    self.m_leftHandDead = true
    self:ShowLeftHand(false)
end

function Actor2031:ShowLeftHand(isShow)
    local com = self:GetComponent()
    if com then
        com:ShowLeftHand(isShow)
    end

    self.m_isLeftHandShow = isShow
end

function Actor2031:RightHandDie()
    self.m_rightHandDead = true
    self:ShowRightHand(false)
end

function Actor2031:ShowRightHand(isShow)
    local com = self:GetComponent()
    if com then
        com:ShowRightHand(isShow)
    end

    self.m_isRightHandShow = isShow
end

function Actor2031:IsLeftHandDead()
    return self.m_leftHandDead
end

function Actor2031:IsRightHandDead()
    return self.m_rightHandDead
end

function Actor2031:HasHurtAnim()
    return false
end

function Actor2031:CanMove(checkAlive)
    return false
end

function Actor2031:LogicUpdate(deltaMS)
    if self.m_handDropHP >= 0 then
       return
    end

    local statusHP = StatusFactoryInst:NewStatusDelayHurt(self.m_handDropHpGiver,  self.m_handDropHP, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_SELF_HURT, 0, BattleEnum.ROUNDJUDGE_NORMAL)
    self:GetStatusContainer():Add(statusHP, self)
    self.m_handDropHP = 0
end

function Actor2031:DropHP(dropHP, giver)
    self.m_handDropHpGiver = giver
    self.m_handDropHP = FixAdd(self.m_handDropHP, dropHP)
end

function Actor2031:NeedBlood()
    return false
end

function Actor2031:OnDie(killerGiver, hpChgReason, killKeyFrame)
    self:InnerDie(true, BattleEnum.ANIM_DIE_NONE, killerGiver, hpChgReason, BattleEnum.DEADMODE_DEFAULT)
    
    if self.m_component then
        self.m_component:ObjectExploded()
    end

    if self.m_ai then
        self.m_ai:OnDie()
    end

    if self.m_statusContainer then
        self.m_statusContainer:ClearBuff(StatusEnum.CLEARREASON_DIE)
    end
end

return Actor2031