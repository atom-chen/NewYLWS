local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local Actor1015Component = BaseClass("Actor1015Component", ActorComponent)

local actorColorType = typeof(CS.Battle_Actor.ActorTranslucentColor) 

function Actor1015Component:CreateActorColor()
    if not IsNull(self.m_gameObject) then
        self.m_actorColor = UIUtil.FindComponent(self.m_transform, actorColorType)
        if IsNull(self.m_actorColor) then
            self.m_actorColor = self.m_gameObject:AddComponent(actorColorType)
        end
    end
end


return Actor1015Component