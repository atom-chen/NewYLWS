local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixNormalize = FixMath.Vector3Normalize

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium20682 = BaseClass("Medium20682", LinearFlyToTargetMedium)


function Medium20682:ArriveDest()
    self:Hurt()
end

function Medium20682:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    if not battleLogic or not skillCfg or not self.m_skillBase then
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

    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local statusHP = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                    judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, statusHP)

        target:OnBeatBack(performer, self.m_skillBase:A())
    end

    if self.m_skillBase:GetLevel() >= 2 then
        local buff = StatusFactoryInst:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, FixIntMul(self.m_skillBase:B(), 1000))
        buff:AddAttrPair(ACTOR_ATTR.PHY_BAOJI_PROB_CHG, FixDiv(self.m_skillBase:Y(), 100))

        self:AddStatus(performer, performer,buff)
    end
end

return Medium20682