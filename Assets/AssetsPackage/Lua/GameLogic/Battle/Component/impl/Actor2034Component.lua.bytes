local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local Actor2034Component = BaseClass("Actor2034Component", ActorComponent)

local Animator = CS.UnityEngine.Animator

function Actor2034Component:__init()
    self.m_idleEffectKey = -1
end

function Actor2034Component:CheckEffect(deltaTime)
    if self.m_animator then
        local stateInfo = self.m_animator:GetCurrentAnimatorStateInfo(0)
        if stateInfo.fullPathHash == self.IdleAnimHash then
            if self.m_idleEffectKey <= 0 then
                self.m_idleEffectKey = EffectMgr:AddEffect(self.m_actor:GetActorID(), 203405)
            end
        else
            if self.m_idleEffectKey > 0 then
                self.m_idleEffectKey = EffectMgr:RemoveByKey(self.m_idleEffectKey)
                self.m_idleEffectKey = -1
            end
        end
    end
end


return Actor2034Component