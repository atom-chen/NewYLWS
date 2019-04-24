local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixMul = FixMath.mul

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20871 = BaseClass("Skill20871", SkillBase)

function Skill20871:Perform(performer, target, performPos, special_param) 
    if not performer or not performer:IsLive() or not target or not target:IsLive() then 
        return 
    end

    -- 挥舞盾牌对选中目标造成{x1}%的物理伤害，并定身{A}秒。
    -- 挥舞盾牌对选中目标造成{x2}%的物理伤害，并定身{A}秒。被盾牌猛击击中的敌人在{C}秒内命中下降{B}%。
    -- 挥舞盾牌对选中目标造成{x3}%的物理伤害，并定身{A}秒。被盾牌猛击击中的敌人在{C}秒内命中下降{B}%。
    -- 挥舞盾牌对选中目标造成{x4}%的物理伤害，并定身{A}秒。被盾牌猛击击中的敌人在{C}秒内命中下降{B}%。


    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
       return 
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local giver =  StatusGiver.New(performer:GetActorID(), 20871)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)
    end 

    local giver = StatusGiver.New(performer:GetActorID(), 20871)
    local dingshenStatus = StatusFactoryInst:NewStatusDingShen(giver, FixIntMul(self:A(), 1000))
    self:AddStatus(performer, target, dingshenStatus) 
   
    local isDingShenStatus = target:GetStatusContainer():IsDingShen()  
    if self.m_level >= 2 and isDingShenStatus then 
        local giver = StatusGiver.New(performer:GetActorID(), 20871)
        local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:C(), 1000))
        buff:AddAttrPair(ACTOR_ATTR.MINGZHONG_PROB_CHG, FixDiv(self:B(), 100))
        self:AddStatus(performer, target, buff)
    end
end

return Skill20871














