local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local FixIntMul = FixMath.muli
local FixSub = FixMath.sub
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR
local IsInCircle = SkillRangeHelper.IsInCircle
local FixNormalize = FixMath.Vector3Normalize
local FixAdd = FixMath.add
local FixMul = FixMath.mul

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill12051 = BaseClass("Skill12051", SkillBase)

function Skill12051:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    -- 公孙瓒一声令下，在本阵后方召唤{A}名白马义从，朝着指定方向发起冲锋，对所有触碰到的敌人造成{x1}%的物理伤害，并击退{B}米。
    -- 公孙瓒一声令下，在本阵后方召唤{A}名白马义从，朝着指定方向发起冲锋，对所有触碰到的敌人造成{x2}%的物理伤害，并击退{B}米。对首个接触的敌人，可将其击飞。
    -- 公孙瓒一声令下，在本阵后方召唤{A}名白马义从，朝着指定方向发起冲锋，对所有触碰到的敌人造成{x3}%的物理伤害，并击退{B}米。对首个接触的敌人，可将其击飞。
    -- 公孙瓒一声令下，在本阵后方召唤{A}名白马义从，朝着指定方向发起冲锋，对所有触碰到的敌人造成{x4}%的物理伤害，并击退{B}米。对首个接触的敌人，可将其击飞。
    -- 公孙瓒一声令下，在本阵后方召唤{A}名白马义从，朝着指定方向发起冲锋，对所有触碰到的敌人造成{x5}%的物理伤害，并击退{B}米。对首个接触的敌人，可将其击飞。公孙瓒的生命低于{E}%时，释放大招可额外召唤一列白马义从。
    -- 公孙瓒一声令下，在本阵后方召唤{A}名白马义从，朝着指定方向发起冲锋，对所有触碰到的敌人造成{x6}%的物理伤害，并击退{B}米。对首个接触的敌人，可将其击飞。公孙瓒的生命低于{E}%时，释放大招可额外召唤一列白马义从。
    -- 阶段6：多召唤一列白马义从的位置如图。多召唤出的这一列冲锋略晚于第一列0.5秒，从而形成连续的控制
 
    local callCount = self:A()
    if self.m_level >= 5 then
        local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local baseHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
        local hpPercent = FixDiv(curHP, baseHP)
        if hpPercent <= FixDiv(self:E(), 100) then
            callCount = FixMul(callCount, 2)
        end
    end

    performer:CalcCallStandIndex(callCount)
end

return Skill12051