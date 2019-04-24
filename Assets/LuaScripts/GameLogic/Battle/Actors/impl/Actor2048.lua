local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2048 = BaseClass("Actor2048", Actor)

function Actor2048:ChangeHP(giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    Actor.ChangeHP(self, giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)

    if self:IsLive() and chgVal < 0 then
        self:AddEffect(20025)
    end
end

return Actor2048