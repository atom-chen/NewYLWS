local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local IsInCircle = SkillRangeHelper.IsInCircle
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20262 = BaseClass("Skill20262", SkillBase)

function Skill20262:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    -- 挑衅
    -- 强迫周围敌人攻击自身，持续{x1}秒。
    -- 强迫周围敌人攻击自身，并增加自身{y2}%物防，持续{x2}秒。

    local time = FixIntMul(self:X(), 1000)
    if self.m_level >= 2 then
        local giver = StatusGiver.New(performer:GetActorID(), 20262)
        local attrBuff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time)
        attrBuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)

        local performerData = performer:GetData()
        local curPhyDef = performerData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
        local chgPhyDef = FixIntMul(curPhyDef, FixDiv(self:Y(), 100))
        attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)

        self:AddStatus(performer, performer, attrBuff)
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local dis2 = self.m_skillCfg.dis2
    local StatusGiverNew = StatusGiver.New
    local performerPos = performer:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(performerPos, dis2, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local giver = StatusGiverNew(performer:GetActorID(), 20262)
            local statusChaofeng = StatusFactoryInst:NewStatusChaoFeng(giver, performer:GetActorID(), time)
            self:AddStatus(performer, tmpTarget, statusChaofeng)
        end
    )
end

return Skill20262