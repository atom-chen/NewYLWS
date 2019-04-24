local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium1061ATK = BaseClass("Medium1061ATK", LinearFlyToTargetMedium)

function Medium1061ATK:__init()
    self.m_hurtMul = 1
end

function Medium1061ATK:InitParam(param)
    LinearFlyToTargetMedium.InitParam(self, param)
    self.m_hurtMul = param.hurtMul
end

function Medium1061ATK:ArriveDest()
    self:Hurt()
end

function Medium1061ATK:Hurt()
    local performer = self:GetOwner()
    if not performer then
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

    local skillCfg = self:GetSkillCfg()
    
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        injure = FixAdd(injure, FixMul(injure, self.m_hurtMul))
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end
end


return Medium1061ATK