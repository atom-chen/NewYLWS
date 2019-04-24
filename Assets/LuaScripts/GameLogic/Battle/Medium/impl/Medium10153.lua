local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR
local StatusEnum = StatusEnum

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium10153 = BaseClass("Medium10153", LinearFlyToTargetMedium)

function Medium10153:ArriveDest()
    self:Hurt()
end


function Medium10153:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                            judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        target:OnBeatBack(performer, self.m_skillBase:A())

        local skillLevel = self.m_skillBase:GetLevel()
        if skillLevel >= 2 then
            local xiaDebuff = StatusFactoryInst:NewStatusXiahouyuanDebuff(self.m_giver, BattleEnum.AttrReason_SKILL, FixIntMul(self.m_skillBase:C(), 1000))
            xiaDebuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)

            local targetPhyDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
            local chgPhyDef = FixIntMul(targetPhyDef, FixDiv(self.m_skillBase:B(), 100))
            xiaDebuff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1))
            self:AddStatus(performer, target, xiaDebuff)
        end
    end
end

return Medium10153