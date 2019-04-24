 
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixMul = FixMath.mul
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20152 = BaseClass("Skill20152", SkillBase)

function Skill20152:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then 
        return 
    end
    --1-2
    --对当前攻击目标造成{x1}%的物理伤害。
    --3-4 
    --对当前攻击目标造成{x3}%的物理伤害，并使其眩晕{A}秒。 

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end
    local giver = StatusGiver.New(performer:GetActorID(), 20152)
    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)
    end

    if self.m_level >= 3 then
        local giver = StatusGiver.New(performer:GetActorID(), 20152)
        local stunBuff = StatusFactoryInst:NewStatusStun(giver, FixIntMul(self:A(), 1000))
        self:AddStatus(performer, target, stunBuff)
    end
end

return Skill20152
