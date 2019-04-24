local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2067 = BaseClass("Actor2067", Actor)


function Actor2067:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end

return Actor2067