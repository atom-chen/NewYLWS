local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixMod = FixMath.mod
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local FixRand = BattleRander.Rand
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium40501 = BaseClass("Medium10062", LinearFlyToTargetMedium)

function Medium40501:ArriveDest()
    self:Hurt()
end

function Medium40501:Hurt()
    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local performer = self:GetOwner()
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
    local addInjure = FixMul(injure, FixDiv(self.m_skillBase:E(), 100))
    injure = FixAdd(injure, addInjure)

    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        local randVal = FixMod(FixRand(), 100)
        if randVal < self.m_skillBase:A() then
            local stunBuff = StatusFactoryInst:NewStatusStun(self.m_giver, 1)
            self:AddStatus(performer, target, stunBuff)
        end
    end
end

return Medium40501