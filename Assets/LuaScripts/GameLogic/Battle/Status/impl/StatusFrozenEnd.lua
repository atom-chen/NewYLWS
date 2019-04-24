local StatusFrozen = require("GameLogic.Battle.Status.impl.StatusFrozen")
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local base = StatusFrozen
local StatusFrozenEnd = BaseClass("StatusFrozenEnd", base)

function StatusFrozenEnd:__init()
    self.m_continueTime = 0
    self.m_yPercent = 0
end

function StatusFrozenEnd:Init(giver, leftMS, continueTime, yPercent, effect)
    base.Init(self, giver, leftMS, effect)

    self.m_continueTime = continueTime
    self.m_yPercent = yPercent
end

function StatusFrozenEnd:ClearEffect(actor)
    if actor and actor:IsLive() then 
        local giverActor = ActorManagerInst:GetActor(self.m_giver.actorID)
        if giverActor and giverActor:IsLive() then
            local buffStatus = StatusFactoryInst:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, self.m_continueTime)  
            local chgMoveSpeed = actor:CalcAttrChgValue(ACTOR_ATTR.BASE_MOVESPEED, self.m_yPercent)
            local chgAtkSpeed = actor:CalcAttrChgValue(ACTOR_ATTR.BASE_ATKSPEED, self.m_yPercent)

            buffStatus:AddAttrPair(ACTOR_ATTR.FIGHT_MOVESPEED, FixMul(chgMoveSpeed, -1))
            buffStatus:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, FixMul(chgAtkSpeed, -1))

            actor:GetStatusContainer():Add(buffStatus, giverActor)  
        end
    end

    base.ClearEffect(self, actor)
end

function StatusFrozenEnd:GetStatusType()
    return StatusEnum.STATUSTYPE_FROZEN_END
end

return StatusFrozenEnd