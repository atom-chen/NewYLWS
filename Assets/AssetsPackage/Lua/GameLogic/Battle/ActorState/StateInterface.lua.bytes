local BattleEnum = BattleEnum

local StateInterface = BaseClass("StateInterface")

function StateInterface:__init(selfActor)
    self.m_selfActor = selfActor
    self.m_execState = BattleEnum.EventHandle_CONTINUE
end

function StateInterface:__delete()
    self.m_selfActor = nil
end

function StateInterface:GetStateID()
end

function StateInterface:SetParam(whatParam, ...)
end

function StateInterface:GetParam(whatParam)
end

function StateInterface:Start(...)
    return true
end

function StateInterface:GetExecState()
    return self.m_execState
end

function StateInterface:Update(deltaMS)
end

function StateInterface:End()
end

function StateInterface:Pause(reason)
end

function StateInterface:Resume(reason)
end

function StateInterface:AnimateHurt()
    return true
end

function StateInterface:AnimateDeath()
    return true
end

function StateInterface:OnAttrChg(attr, oldVal, newVal)
end

function StateInterface:OnFightEnd()
end

return StateInterface