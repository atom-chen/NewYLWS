local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill20104 = BaseClass("Skill20104", AtkFunc1)

function Skill20104:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end
    AtkFunc1.Perform(self, performer, target, performPos, special_param)
    performer:FollowAttack(target:GetActorID())
end

return Skill20104