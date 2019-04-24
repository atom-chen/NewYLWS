local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2001 = BaseClass("Actor2001", Actor)

function Actor2001:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end

return Actor2001