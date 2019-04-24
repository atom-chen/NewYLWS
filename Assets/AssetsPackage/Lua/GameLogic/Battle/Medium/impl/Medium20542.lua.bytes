local FixDiv = FixMath.div
local FixMul = FixMath.mul
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR
local StatusGiver = StatusGiver
local FixIntMul = FixMath.muli

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium20542 = BaseClass("Medium20542", LinearFlyToTargetMedium)

function Medium20542:ArriveDest()
    self:Hurt()
end

function Medium20542:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
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
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                judge, self.m_param.keyFrame)

        self:AddStatus(performer, target, status)

        local giver = StatusGiver.New(performer:GetActorID(), 20542)
        local frozenStatus = StatusFactoryInst:NewStatusFrozen(giver, FixIntMul(self.m_skillBase:B(), 1000))
        self:AddStatus(performer, target, frozenStatus)

        --被冰矢冰冻的敌人在<color=#1aee00>{C}</color>秒内的物防、法防各下降<color=#1aee00>{D}%</color>。
        if self.m_skillBase:GetLevel() == 2 then
            local buff = StatusFactoryInst:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, FixMul(self.m_skillBase:C(), 1000))
        
            local targetPhyDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
            local chgPhyDef = FixIntMul(targetPhyDef, FixDiv(self.m_skillBase:D(), 100))
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1))

            local targetMagicDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
            local chgMagicDef = FixIntMul(targetMagicDef, FixDiv(self.m_skillBase:D(), 100))

            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, FixMul(chgMagicDef, -1))
            self:AddStatus(performer, target, buff)
        end
    end
end


return Medium20542