local BattleEnum = BattleEnum

local FixNewVector3 = FixMath.NewFixVector3

local StateInterface = require "GameLogic.Battle.ActorState.StateInterface"
local DeadState = BaseClass("DeadState", StateInterface)

function DeadState:__init(selfActor)

end

function DeadState:GetStateID()
    return BattleEnum.ActorState_DEAD
end

function DeadState:Start(...)
    self.m_execState = BattleEnum.EventHandle_END

    DieShowMgr:DieShow(...)

    return true
end

function DeadState:End()
   
end

function DeadState:Update(deltaMS)

end

function DeadState:AnimateHurt()
    return false
end

function DeadState:AnimateDeath()
    return false
end

return DeadState