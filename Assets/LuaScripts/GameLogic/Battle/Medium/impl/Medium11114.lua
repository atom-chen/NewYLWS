local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium11114 = BaseClass("Medium11114", LinearFlyToTargetMedium)

function Medium11114:ArriveDest()
    self:Hurt()
end

function Medium11114:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local factor = nil
    local chgPhyDefPercent = performer:Get11113X()
    if chgPhyDefPercent > 0 then
        factor = Factor.New()
        if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            chgPhyDefPercent = 1
            local curMagicDef = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_DEF)
            factor.chgMagicDef = FixMul(curMagicDef, -1)
        end

        local curPhyDef = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)
        local chgPhyDef = FixIntMul(curPhyDef, chgPhyDefPercent)
        factor.chgPhyDef = FixMul(chgPhyDef, -1)
    end

    local factory = StatusFactoryInst
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X(), factor)
    if injure > 0 then
        local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end
end


return Medium11114