local FixMul = FixMath.mul
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local Factor = Factor

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local NormalFly = BaseClass("NormalFly", LinearFlyToTargetMedium)

function NormalFly:ArriveDest()
    self:Hurt()
end

function NormalFly.CreateParam(targetActorID, keyFrame, speed, hurtType)
    local p = {
        targetActorID = targetActorID,
        keyFrame = keyFrame,
        speed = speed,
        hurtType = hurtType
    }
    return p
end


function NormalFly:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local skillCfg = self:GetSkillCfg()
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end
    
    if self.m_param.reason == BattleEnum.HPCHGREASON_NONE then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, self.m_param.hurtType, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end
    
    local injure = Formular.CalcInjure(performer, target, skillCfg, self.m_param.hurtType, judge, self.m_skillBase:X())
    if injure > 0 then

        self:OnHurt(target)

        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), self.m_param.hurtType, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end
end

function NormalFly:OnHurt(target)
end

return NormalFly