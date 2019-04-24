local FixMul = FixMath.mul
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixAdd = FixMath.add

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium1006ATK = BaseClass("Medium1006ATK", LinearFlyToTargetMedium)

function Medium1006ATK:ArriveDest()
    self:Hurt()
end

function Medium1006ATK:Hurt()
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
        performer:InterrupteAtk()
        return  
    end

    if performer:Get10063BaojiAttr() then
        judge = BattleEnum.ROUNDJUDGE_BAOJI
    end

    performer:ContinueAtk()

    local factory = StatusFactoryInst
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    --每次普攻连续命中都能降低目标<color=#ffb400>{x1}%</color>的闪避，并令自身的普攻伤害提升<color=#ffb400>{y1}%</color>%，可无限累加
    if injure > 0 then
        local curHurtMul = performer:GetAtkHurtMul()
        injure = FixMul(injure, FixAdd(curHurtMul, 1))
        local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end

    performer:ReduceSBShanbi(target) 
end


return Medium1006ATK