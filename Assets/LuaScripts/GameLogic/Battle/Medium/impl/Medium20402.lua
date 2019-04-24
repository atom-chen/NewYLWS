local FixMul = FixMath.mul
local FixAdd = FixMath.add
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst

local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")
local Medium20402 = BaseClass("Medium20402", NormalFly)

function Medium20402:Hurt()
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
    
    local injure = Formular.CalcInjure(performer, target, self:GetSkillCfg(), BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:Y())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        local giver = StatusGiver.New(performer:GetActorID(), 20402)   
        local dingshenStatus = StatusFactoryInst:NewStatusDingShen(giver, FixMul(self.m_skillBase:A(), 1000))
        self:AddStatus(performer, target, dingshenStatus)
    end
end

return Medium20402