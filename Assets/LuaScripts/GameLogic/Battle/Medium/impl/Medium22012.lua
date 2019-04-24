local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local StatusEnum = StatusEnum
local StatusGiver = StatusGiver
local FixRand = BattleRander.Rand
local FixMod = FixMath.mod
local IsInCircle = SkillRangeHelper.IsInCircle

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium22012 = BaseClass("Medium22012", LinearFlyToTargetMedium)

function Medium22012:ArriveDest()
    self:Hurt()
end

function Medium22012:Hurt()
    local performer = self:GetOwner()
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not performer or not target or not target:IsLive() then
        return
    end   
    
    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end 
    --发射飞刀对当前目标造成<color=#ffb400>{x1}%</color>的物理伤害，并令其失明，命中率率下降<color=#ffb400>{y1}%</color>，持续<color=#1aee00>{A}</color>秒。
    --发射飞刀对当前目标造成<color=#ffb400>{x2}%</color>的物理伤害，并令其失明，命中率率下降<color=#ffb400>{y2}%</color>，持续<color=#1aee00>{A}</color>秒。
    --并令下次普攻可以溅射<color=#1aee00>{B}</color>米内的敌人
    local skillCfg = self:GetSkillCfg() 
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, 
                                        BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)

        self:AddStatus(performer, target, status) 
    end

    local time = FixIntMul(self.m_skillBase:A(), 1000)
    local buff = StatusFactoryInst:NewStatusChengyuDeBuff(self.m_giver, BattleEnum.AttrReason_SKILL, time)
    buff:AddAttrPair(ACTOR_ATTR.MINGZHONG_PROB_CHG, FixDiv(self.m_skillBase:Y(), -100))
    buff:SetMergeRule(StatusEnum.MERGERULE_TOGATHER)
    local addSuc = self:AddStatus(performer, target, buff)
    if addSuc then
        local intervalDebuff = target:GetStatusContainer():GetChengyuLongTimeIntervalDebuff()
        if intervalDebuff then
            intervalDebuff:SyncLeftMS(time)
        end
    end

    local skillLevel = self.m_skillBase:GetLevel()
    if skillLevel >= 2 then
        performer:Launch22012TakeAtk()
    end 
end 
 
return Medium22012