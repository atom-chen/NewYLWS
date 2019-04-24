local FixDiv = FixMath.div
local FixMul = FixMath.mul
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium10381 = BaseClass("Medium10381", LinearFlyToTargetMedium)

function Medium10381:ArriveDest()
    self:Hurt()
end

function Medium10381:Hurt()
    local performer = self:GetOwner()
    if not performer then
        performer:ResetSkill10381InjureMul()
        return
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        performer:ResetSkill10381InjureMul()
        return
    end

    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        performer:ResetSkill10381InjureMul()
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        performer:ResetSkill10381InjureMul()
        return  
    end
    local skillLevel = self.m_skillBase:GetLevel()

    if skillLevel >= 3 then
        performer:ChangeNuqi(self.m_skillBase:A(), BattleEnum.NuqiReason_SKILL_RECOVER, skillCfg)
    end

    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if skillLevel >= 6 then
        local injureMul = performer:GetSkill10381InjureMul()
        injure = FixMul(injure, injureMul)

        if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            performer:AddSkill10381InjureMul(FixDiv(self.m_skillBase:Y(), 100))
        else
            performer:ResetSkill10381InjureMul()
        end

        if self.m_param.keyFrame == 6 then
            performer:ResetSkill10381InjureMul() 
        end
    end

    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end
end


return Medium10381