local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular
local StatusGiver = StatusGiver


local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium20112 = BaseClass("Medium20112", LinearFlyToTargetMedium)

function Medium20112:ArriveDest()
    self:Hurt()
end

function Medium20112:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    if not battleLogic or not skillCfg or not self.m_skillBase then
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
    --对当前攻击目标造成{x1}%的物理伤害，并令其攻速与移速各下降{A}%，持续{B}秒。
    --对当前攻击目标造成{x2}%的物理伤害，并令其攻速与移速各下降{A}%，持续{B}秒。
    --若目标处于流血状态，则攻速移速下降的效果翻倍。

    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X()) 
    if injure > 0 then 
        local giver =  StatusGiver.New(performer:GetActorID(), 20112)
        local hpStatus = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self.m_skillBase:AddStatus(performer, target, hpStatus)
    end

    local giver = StatusGiver.New(performer:GetActorID(), 20112) 
    local buffStatus = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self.m_skillBase:B(), 1000))  

    local decMul = FixDiv(self.m_skillBase:A(), 100)
    local curMoveSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
    local chgMoveSpeed = FixIntMul(curMoveSpeed, decMul)
    local curAtkSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
    local chgAtkSpeed = FixIntMul(curAtkSpeed, decMul)
    
    if self.m_skillBase:GetLevel() >= 2 then
        local intervalHpStatus = target:GetStatusContainer():GetIntervalHP20111()
        if intervalHpStatus then
            chgMoveSpeed = FixIntMul(chgMoveSpeed, 2)
            chgAtkSpeed = FixIntMul(chgAtkSpeed, 2)
        end
    end

    buffStatus:AddAttrPair(ACTOR_ATTR.FIGHT_MOVESPEED, FixMul(chgMoveSpeed, -1))
    buffStatus:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, FixMul(chgAtkSpeed, -1))

    self.m_skillBase:AddStatus(performer, target, buffStatus) 
end

return Medium20112