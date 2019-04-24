 
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixMul = FixMath.mul 

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20862 = BaseClass("Skill20862", SkillBase)

function Skill20862:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then 
        return 
    end

    -- 蓄力{A}秒，后对当前攻击目标造成{x1}%的物理伤害。
    -- 蓄力{A}秒，后对当前攻击目标造成{x2}%的物理伤害。
    -- 蓄力{A}秒，后对当前攻击目标造成{x3}%的物理伤害，蓄力过程中霸体。
    -- 蓄力{A}秒，后对当前攻击目标造成{x4}%的物理伤害。

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end
     
    local giver = StatusGiver.New(performer:GetActorID(), 20862)
    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, 
        BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)
    end      
end

function Skill20862:Preperform(performer, target, performPos)
    if self.m_level >= 3 then 
        local time = FixMul(self:A(), 1000)
        local giver = StatusGiver.New(performer:GetActorID(), 20862)
        local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, time)
        immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
        immuneBuff:SetCanClearByOther(false)
        self:AddStatus(performer, performer, immuneBuff)
    end 
end

return Skill20862