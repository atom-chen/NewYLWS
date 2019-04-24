local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium10382 = BaseClass("Medium10382", LinearFlyToTargetMedium)

function Medium10382:ArriveDest()
    self:Hurt()
end

function Medium10382:Hurt()
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

    local buff = StatusFactoryInst:NewStatusSunshangxiangDeBuff(self.m_giver, BattleEnum.AttrReason_SKILL, FixIntMul(self.m_skillBase:A(), 1000))

    local chgPercent = FixDiv(self.m_skillBase:Y(), -100)
    local chgPhyDefValue = target:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_DEF, chgPercent)
    local chgMagicDefValue = target:CalcAttrChgValue(ACTOR_ATTR.BASE_MAGIC_DEF, chgPercent)
    buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDefValue)
    self:AddStatus(performer, target, buff)

    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end
end


return Medium10382