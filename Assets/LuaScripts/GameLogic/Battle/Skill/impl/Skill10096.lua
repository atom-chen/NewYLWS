local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local IsInCircle = SkillRangeHelper.IsInCircle
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10096 = BaseClass("Skill10096", SkillBase)

function Skill10096:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    
    -- 子午奇袭
    -- 1-2
    -- 魏延一声令下，召唤1名精锐武卒，同时号令所有精锐武卒立即突进攻击b米内当前生命值最低的敌人，并为武卒临时附加持续{A}秒的狂暴状态。
    -- 处于狂暴状态下的武卒免疫一切控制状态，物理暴击与暴击伤害额外提升{x1}%。
    -- 3-6
    -- 魏延一声令下，召唤1名精锐武卒，同时号令所有精锐武卒立即突进攻击b米内当前生命值最低的敌人，并为武卒临时附加持续{A}秒的狂暴状态。
    -- 处于狂暴状态下的武卒免疫一切控制状态，物理暴击与暴击伤害额外提升{x3}%、移速与攻速额外提升{y3}%。

    performer:Call()

    local speedPercent = 0
    if self.m_level>= 3 then
        speedPercent = FixDiv(self:Y(), 100)
    end
    
    performer:AddWuzuKuangbao(FixIntMul(self:A(), 1000), FixDiv(self:X(), 100), speedPercent)

    local minHP = 999999999999
    local minHPTarget = nil
    local logic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(performer:GetPosition(), self:B(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local tmpCurHP = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if tmpCurHP < minHP then
                minHPTarget = tmpTarget
            end
        end
    )

    if minHPTarget then
        performer:SetWuzuFocusAtkTargetID(minHPTarget:GetActorID())
    end
end


return Skill10096