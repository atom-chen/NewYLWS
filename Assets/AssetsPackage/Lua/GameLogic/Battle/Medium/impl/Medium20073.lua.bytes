local FixMul = FixMath.mul
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local StatusFactoryInst = StatusFactoryInst

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium20073 = BaseClass("Medium20073", LinearFlyToTargetMedium)

function Medium20073:ArriveDest()
    self:Hurt()
end

function Medium20073:Hurt()
    -- 西凉弓箭手普攻1

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
    local statusWeak = target:GetStatusContainer():GetXiliangWeak(performer:GetActorID())
    if statusWeak then
        local hurtMul = statusWeak:GetHurtMul()
        injure = FixMul(hurtMul, injure)
    end

    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end
end

return Medium20073