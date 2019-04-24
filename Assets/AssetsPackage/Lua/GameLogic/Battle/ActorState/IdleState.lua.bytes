local BattleEnum = BattleEnum

local StateInterface = require "GameLogic.Battle.ActorState.StateInterface"
local IdleState = BaseClass("IdleState", StateInterface)

function IdleState:__init(selfActor)
    self.m_idleType = BattleEnum.IdleType_STAND
    self.m_reason = BattleEnum.IdleReason_NORMAL
end

function IdleState:GetStateID()
    return BattleEnum.ActorState_IDLE
end

function IdleState:Start(...)
    local idleType, forceAnim, reason = ...
    self:ChangeIdleType(idleType, forceAnim, reason)

    return true
end

function IdleState:ChangeIdleType(idleType, forceAnim, reason)
    if not forceAnim and idleType == m_idleType then
        return
    end

    self.m_idleType = idleType
    self.m_reason = reason

    if idleType == BattleEnum.IdleType_STAND then
        self.m_selfActor:PlayAnim(BattleEnum.ANIM_IDLE)

    elseif idleType == BattleEnum.IdleType_STUN then
        self.m_selfActor:PlayAnim(BattleEnum.ANIM_STUN)

    elseif idleType == BattleEnum.IdleType_SLEEP then
        self.m_selfActor:PlayAnim(BattleEnum.ANIM_STUN)

    elseif idleType == BattleEnum.IdleType_WIN then
        self.m_selfActor:PlayAnim(BattleEnum.ANIM_WIN)
    end    
end

function IdleState:AnimateHurt()
    return self.m_idleType == BattleEnum.IdleType_STAND 
end

function IdleState:AnimateDeath()
    return true
end

function IdleState:GetReason()
    return self.m_reason
end

return IdleState