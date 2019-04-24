local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixMod = FixMath.mod
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixRand = BattleRander.Rand
local ACTOR_ATTR = ACTOR_ATTR

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium10062 = BaseClass("Medium10062", LinearFlyToTargetMedium)

function Medium10062:ArriveDest()
    self:Hurt()
end

function Medium10062:Hurt()
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

    if performer:Get10063BaojiAttr() then
        judge = BattleEnum.ROUNDJUDGE_BAOJI
    end

    local factory = StatusFactoryInst
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end

    local skillLevel = self.m_skillBase:GetLevel()
    if skillLevel >= 3 then
        local performerPos = performer:GetPosition()
        local disSqr = (performerPos - target:GetPosition()):SqrMagnitude()
        local A = self.m_skillBase:A()
        if disSqr < FixMul(A, A) then
            target:OnBeatBack(performer, self.m_skillBase:B())
        end

        if skillLevel >= 6 and self.m_param.keyFrame == 3 then
            local randVal = FixMod(FixRand(), 100)
            local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            local baseHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
            local chgHPPercent = FixDiv(FixSub(baseHP, curHP), baseHP)
            chgHPPercent = FixIntMul(chgHPPercent, 100)
            if chgHPPercent > 10 then
                local value = FixMod(chgHPPercent, 10)
                randVal = FixSub(randVal, FixMul(value, self.m_skillBase:D()))
            end
            if randVal <= self.m_skillBase:C() then
                performer:ShouldResetSkill10062CD()
            end
        end
    end
end


return Medium10062