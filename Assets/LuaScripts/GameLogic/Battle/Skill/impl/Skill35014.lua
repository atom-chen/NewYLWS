local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local CtlBattleInst = CtlBattleInst
local FixIntMul = FixMath.muli
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill35014 = BaseClass("Skill35014", SkillBase)

function Skill35014:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --青龙伸出左爪，横向扫击当前生命值最高的敌人，造成{x1}（+{E}%物攻)点物理伤害并且附加持续{A}秒的青龙刻印：期间青龙受到的所有伤害会反弹到该名目标身上

    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New

    if not CtlBattleInst:GetLogic():IsEnemy(performer, target, BattleEnum.RelationReason_SKILL_RANGE) then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local giver = statusGiverNew(performer:GetActorID(), 35014)
        local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)

        local buff = factory:NewStatusQingLongMark(giver, FixIntMul(self:A(), 1000), target:GetActorID())
        self:AddStatus(performer, performer, buff)
    end
    
end

function Skill35014:SelectSkillTarget(performer, target)
    local maxHPTarget = self:GetMaxHPActor(false, performer, false)

    if maxHPTarget then
        return maxHPTarget, maxHPTarget:GetPosition()
    end

    return SkillBase.SelectSkillTarget(self, performer, target)
end

return Skill35014