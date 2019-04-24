local FixMul = FixMath.mul
local FixAdd = FixMath.add
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local IsInCircle = SkillRangeHelper.IsInCircle

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium1022ATK = BaseClass("Medium1022ATK", LinearFlyToTargetMedium)

function Medium1022ATK:InitParam(param)
    LinearFlyToTargetMedium.InitParam(self, param)
    self.m_param.radius = param.radius
    self.m_param.hurtPercent = param.hurtPercent
end

function Medium1022ATK:ArriveDest()
    self:Hurt()
end

function Medium1022ATK:Hurt()
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
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        if self.m_mediumID == 82 then
            performer:ActiveFengleichiEffect(target, self.m_param.radius, FixMul(injure, self.m_param.hurtPercent))
        --     local battleLogic = CtlBattleInst:GetLogic()
        --     local radius = self.m_param.radius
        --     local hurtPercent = self.m_param.hurtPercent
        --     local targetPos = target:GetPosition()
        --     local targetID = target:GetActorID()
        --     ActorManagerInst:Walk(
        --         function(tmpTarget)
        --             if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
        --                 return
        --             end

        --             if tmpTarget:GetActorID() == targetID then
        --                 return
        --             end

        --             if not IsInCircle(targetPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
        --                 return
        --             end
                    
        --             local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
        --             if Formular.IsJudgeEnd(judge) then
        --                 return  
        --             end

        --             injure = FixMul(injure, hurtPercent)
        --             if injure > 0 then
        --                 local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
        --                                                                                                                     judge, self.m_param.keyFrame)
        --                 self:AddStatus(performer, tmpTarget, status)
        --             end
        --         end
        --     )
        end
    end
end

return Medium1022ATK