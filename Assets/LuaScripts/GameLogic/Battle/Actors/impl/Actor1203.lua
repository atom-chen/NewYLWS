local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1203 = BaseClass("Actor1203", Actor)

function Actor1203:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end

return Actor1203