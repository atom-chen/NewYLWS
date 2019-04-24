local StatusGiver = StatusGiver
local BattleEnum = BattleEnum
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20703 = BaseClass("Skill20703", SkillBase)

function Skill20703:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    -- 激流
    -- 召唤一道水流冲击当前攻击目标，造成{x1}%的法术伤害并使其物理防御降低{A}%。
    -- 召唤一道水流冲击当前攻击目标，造成{x2}%的法术伤害并使其物理防御降{A}%。
    -- 召唤一道水流冲击当前攻击目标，造成{x3}%的法术伤害并使其物理防御降{A}%。
    -- 召唤一道水流冲击当前攻击目标，造成{x4}%的法术伤害并使其物理防御降{A}%。使用“激流”时，水行妖也会对其当前攻击目标施放“激流”。

    if self.m_level >= 4 then
        performer:ShuiyaoPerformJL(target:GetActorID())
    end
    target:AddEffect(207006)
    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 20703)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)

        local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000))
        local targetData = target:GetData()
        local targetPhyDef = targetData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
        local chgPhyDef = FixIntMul(targetPhyDef, FixDiv(self:A(), 100))
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1))
        self:AddStatus(performer, target, buff)
    end
end


return Skill20703