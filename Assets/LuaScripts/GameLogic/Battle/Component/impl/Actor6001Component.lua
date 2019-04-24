local PreloadHelper = PreloadHelper
local GameObjectPoolInst = GameObjectPoolInst
local GameUtility = CS.GameUtility
local Utils = Utils
local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local Actor6001Component = BaseClass("Actor6001Component", ActorComponent)

function Actor6001Component:OnBorn(actor_go, actor)
    ActorComponent.OnBorn(self, actor_go, actor)

    local y = Utils.RandomBetween(1, 180)

    GameUtility.RotateByEuler(self.m_transform, 0, y, 0)
end

return Actor6001Component