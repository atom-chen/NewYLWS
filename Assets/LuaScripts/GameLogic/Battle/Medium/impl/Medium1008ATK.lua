local FixMul = FixMath.mul
local FixAdd = FixMath.add
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium1008ATK = BaseClass("Medium1008ATK", LinearFlyToTargetMedium)

function Medium1008ATK:ArriveDest()
    self:Hurt()
end

function Medium1008ATK:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end
    
    local injure = Formular.CalcInjure(performer, target, self:GetSkillCfg(), BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local mark = target:GetStatusContainer():GetPangtongTiesuoMark()
        if mark then
            local injureMul = performer:GetTieSuoHurtMul()
            if injureMul > 0 then
                injure = FixAdd(injure, FixMul(injure, injureMul))
            end
        end
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end
end

return Medium1008ATK