local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium1035Atk = BaseClass("Medium1035Atk", LinearFlyToTargetMedium)

function Medium1035Atk:ArriveDest()
    self:Hurt()
end

function Medium1035Atk:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local skillcfg = self:GetSkillCfg()
    if not skillcfg then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    local injure = Formular.CalcInjure(performer, target, skillcfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
        
        if performer:Get1035StealAtkCount(target:GetActorID()) <= performer:Get10353A() then
            -- 加成整场战斗生效，小乔死亡时也不会退还
            local reducePercent = performer:Get10353X()
            local curPhyAtk = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
            local chgPhyAtk = FixIntMul(curPhyAtk, reducePercent)
            local curMagicAtk = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
            local chgMagicAtk = FixIntMul(curMagicAtk, reducePercent)

            target:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(chgPhyAtk, -1))
            target:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, FixMul(chgMagicAtk, -1))
            
            performer:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
            performer:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk, false)

            performer:Add1035StealAtkCount(target:GetActorID())
        end
    end
end


return Medium1035Atk