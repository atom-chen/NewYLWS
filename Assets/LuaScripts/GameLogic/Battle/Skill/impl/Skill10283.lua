local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10283 = BaseClass("Skill10283", SkillBase)

function Skill10283:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    -- 人尽其才
    -- 孙权激发麾下潜能，令己方所有其他角色的物理攻击和法术攻击获得孙权{x1}%的加成，持续{A}秒。
    -- 孙权激发麾下潜能，令己方所有其他角色的物理攻击和法术攻击获得孙权{x2}%的加成，持续{A}秒。
    -- 孙权激发麾下潜能，令己方所有其他角色的物理攻击和法术攻击获得孙权{x3}%的加成，持续{A}秒。每当孙权受到伤害时，就缩短人尽其才技能{y3}%的当前冷却时间。
    -- 孙权激发麾下潜能，令己方所有其他角色的物理攻击和法术攻击获得孙权{x4}%的加成，持续{A}秒。每当孙权受到伤害时，就缩短人尽其才技能{y4}%的当前冷却时间。
    -- 孙权激发麾下潜能，令己方所有其他角色的物理攻击和法术攻击获得孙权{x5}%的加成，持续{A}秒。每当孙权受到伤害时，就缩短人尽其才技能{y5}%的当前冷却时间。
    -- 孙权激发麾下潜能，令己方所有其他角色的物理攻击和法术攻击获得孙权{x6}%的加成，持续{A}秒。每当孙权受到伤害时，就缩短人尽其才技能{y6}%的当前冷却时间。

    local selfActorID = performer:GetActorID()
    local logic = CtlBattleInst:GetLogic()
    local time = FixIntMul(self:A(), 1000)
    local attrPercent = FixDiv(self:X(), 100)
    local chgPhyAtk = performer:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_ATK, attrPercent)
    local chgMagicAtk = performer:CalcAttrChgValue(ACTOR_ATTR.BASE_MAGIC_ATK, attrPercent)

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsFriend(performer, tmpTarget, false) then
                return
            end

            local giver = StatusGiver.New(selfActorID, 10283)
            local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk)
            buff:SetMergeRule(StatusEnum.MERGERULE_TOGATHER)
            self:AddStatus(performer, tmpTarget, buff)
        end
    )

    if self.m_level >= 3 then
        local giver = StatusGiver.New(selfActorID, 10283)
        local buff = StatusFactoryInst:NewStatusSunquanBuff(giver, time, FixDiv(self:Y(), 100), {102809})
        buff:SetMergeRule(StatusEnum.MERGERULE_TOGATHER)
        self:AddStatus(performer, performer, buff)
    end
end


return Skill10283