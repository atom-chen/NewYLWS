local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10613 = BaseClass("Skill10613", SkillBase)
local BattleEnum = BattleEnum

local FixIntMul = FixMath.muli
local FixDiv = FixMath.div

function Skill10613:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    if special_param.keyFrameTimes == 1 then
        performer:Active10613(FixIntMul(self:A(), 1000), FixIntMul(self:D(), 1000), self:B(), FixDiv(self:X(), 100), FixDiv(self:C(), 100))
    end

    if special_param.keyFrameTimes == 2 then
        if self.m_level >= 4 then
            performer:ChangeNuqi(self:Y(), BattleEnum.NuqiReason_SKILL_RECOVER, self.m_skillCfg)
        end
        performer:EndJiejie()
    end
end

return Skill10613