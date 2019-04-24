local CtlBattleInst = CtlBattleInst
local FixNormalize = FixMath.Vector3Normalize

local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill32071 = BaseClass("Skill32071", AtkFunc1)

function Skill32071:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    performer:PerformActiveSkill()
end

return Skill32071