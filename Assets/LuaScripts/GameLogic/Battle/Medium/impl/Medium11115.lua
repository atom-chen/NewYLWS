local FixMul = FixMath.mul
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium11115 = BaseClass("Medium11115", LinearFlyToTargetMedium)

function Medium11115:ArriveDest()
    self:Hurt()
end

function Medium11115:Hurt()
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

    local factory = StatusFactoryInst
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        local baetBackDis = performer:Get11113A()
        if baetBackDis > 0 then
            if judge == BattleEnum.ROUNDJUDGE_BAOJI and performer:Get11113Level() >= 4 then
                baetBackDis = FixMul(baetBackDis, 2)
            end

            target:OnBeatBack(performer, baetBackDis)
        end
    end
end


return Medium11115