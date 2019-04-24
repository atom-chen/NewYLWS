local StatusGiver = StatusGiver
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10212 = BaseClass("Skill10212", SkillBase)

function Skill10212:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then 
        return 
    end

    -- 冻绝之莲 1-2
    -- 荀彧在当前攻击目标身上召唤一朵冰莲，{A}秒内对其造成每秒{x1}%的法术伤害。冰莲消失时令其冰冻{B}秒。
    -- 3-4
    -- 荀彧在当前攻击目标身上召唤一朵冰莲，{A}秒内对其造成每秒{x3}%的法术伤害，并降低{y3}%攻击速度。冰莲消失时令其冰冻{B}秒。
    -- 5-6
    -- 荀彧在当前攻击目标身上召唤一朵冰莲，{A}秒内对其造成每秒{x5}%的法术伤害，并降低{y5}%攻击速度。冰莲消失时令其冰冻{B}秒。
    -- 每当冰莲消失时，以{z5}%几率立即在其他随机敌人身上召唤一朵新的冰莲。
    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
    if injure > 0 then
        local atkPercent = 0
        local rand = 0
        if self.m_level >= 3 then
            atkPercent = FixDiv(self:Y(), 100)
            if self.m_level >= 5 then
                rand = self:Z()
            end
        end

        local giver = StatusGiver.New(performer:GetActorID(), 10212)
        local xunyuIntervalHP = StatusFactoryInst:NewStatusXunyuIntervalHP(giver, FixMul(injure, -1), 1000, self:A(), {102105}, 
                                                                            nil ,FixIntMul(self:B(), 1000), atkPercent, rand)

        self:AddStatus(performer, target, xunyuIntervalHP)
    end
end

return Skill10212