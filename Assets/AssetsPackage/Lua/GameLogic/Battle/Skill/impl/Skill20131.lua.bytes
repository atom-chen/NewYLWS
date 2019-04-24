local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixMul = FixMath.mul

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20131 = BaseClass("Skill20131", SkillBase)

function Skill20131:Perform(performer, target, performPos, special_param) 
    if not performer or not performer:IsLive() or not target or not target:IsLive() then 
        return 
    end

    --挥舞盾牌对当前攻击目标造成{x1}%的物理伤害，并定身{A}秒。
    --挥舞盾牌对当前攻击目标造成{x2}%的物理伤害，并定身{A}秒。被盾牌猛击击中的敌人在{C}秒内命中下降{B}%。

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
       return 
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local giver =  StatusGiver.New(performer:GetActorID(), 20131)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)
    end 

    local giver = StatusGiver.New(performer:GetActorID(), 20131)
    local dingshenStatus = StatusFactoryInst:NewStatusDingShen(giver, FixIntMul(self:A(), 1000))
    self:AddStatus(performer, target, dingshenStatus) 
   
    local isDingShenStatus = target:GetStatusContainer():IsDingShen()  
    if self.m_level >= 2 and isDingShenStatus then 
        local curMingZhong = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG)
        local chgMingZhong = FixIntMul(curMingZhong, FixDiv(self:B(), 100)) 

        local giver = StatusGiver.New(performer:GetActorID(), 20131)
        local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:C(), 1000))
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_MINGZHONG, FixMul(chgMingZhong, -1))
        self:AddStatus(performer, target, buff)
    end
end

return Skill20131














