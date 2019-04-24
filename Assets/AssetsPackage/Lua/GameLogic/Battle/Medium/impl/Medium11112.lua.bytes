local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium11112 = BaseClass("Medium11112", LinearFlyToTargetMedium)

function Medium11112:ArriveDest()
    self:Hurt()
end

function Medium11112:Hurt()
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
    local skillLevel = self.m_skillBase:GetLevel()
    local stunTime = 0
    if judge == BattleEnum.ROUNDJUDGE_BAOJI and skillLevel >= 2 then
        stunTime = FixIntMul(self.m_skillBase:B(), 1000)
    else
        stunTime = FixIntMul(self.m_skillBase:A(), 1000)
    end

    local factory = StatusFactoryInst
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X(), factor)
    if injure > 0 then
        local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        local stunBuff = factory:NewStatusStun(self.m_giver, stunTime)
        self:AddStatus(performer, target, stunBuff)
    end

    if skillLevel >= 5 then
        local curAtkSpeed = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_ATKSPEED)
        local chgAtkSpeed = FixIntMul(curAtkSpeed, FixDiv(self.m_skillBase:Y(), 100))
        local buff = factory:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, FixIntMul(self.m_skillBase:C(), 1000))
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
        self:AddStatus(performer, performer, buff)
    end
end


return Medium11112