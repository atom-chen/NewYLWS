local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIWolf = BaseClass("AIWolf", AIManual)

function AIWolf:__init(actor)
    self.m_aiType = BattleEnum.AITYPE_XILIANGWOLF
    self.m_ownerAtkTargetID = 0
end

function AIWolf:AI(deltaMS)
    local owner = ActorManagerInst:GetActor(self.m_selfActor:GetOwnerID())
    if not owner or not owner:IsLive() then
        return
    end
    
    if self.m_ownerAtkTargetID <= 0 then
        return
    end

    self.m_currTargetActorID = self.m_ownerAtkTargetID
    -- self.m_ownerAtkTargetID = 0

    AIManual.AI(self, deltaMS)
end

function AIWolf:Attack(targetID)
    self.m_ownerAtkTargetID = targetID
end

function AIWolf:CanAI()
    if self.m_selfActor == nil then
        return false
    end

    if self.m_selfActor:IsLive() == false then
        return false
    end

    if self.m_selfActor:CanAction() == false then
        return false
    end

    return true
end

return AIWolf