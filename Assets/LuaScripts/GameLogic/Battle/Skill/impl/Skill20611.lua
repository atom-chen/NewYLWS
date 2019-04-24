local BattleEnum = BattleEnum
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local NewFixVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local FixMod = FixMath.mod 
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20611 = BaseClass("Skill20611", SkillBase)

function Skill20611:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 20611)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)

        local targetData = target:GetData()
        local targetPhyDef = targetData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
        local chgPhyDef = FixIntMul(targetPhyDef, FixDiv(self:A(), 100))
        targetData:AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1))
    end

    local effectPercent = performer:GetAtkEffectPercent()
    if effectPercent > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 20611)
        local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, performer:GetAtkEffectTime())
        local targetData = target:GetData()
        local targetAtkSpeed = targetData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
        local chgAtkSpeed = FixIntMul(targetAtkSpeed, effectPercent)
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, FixMul(chgAtkSpeed, -1))
        self:AddStatus(performer, target, buff)
    end
end



return Skill20611