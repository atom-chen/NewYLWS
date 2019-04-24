local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local AtkFunc4 = BaseClass("AtkFunc4", SkillBase)
local StatusGiver = StatusGiver
local Formular = Formular
local FixMul = FixMath.mul
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum

--法术近程
function AtkFunc4:__init(skill_cfg, level)
end

function AtkFunc4:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    if not target:IsValid() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                judge, special_param.keyFrameTimes)
                                 
        self:AddStatus(performer, target, status)
    end
end

return AtkFunc4