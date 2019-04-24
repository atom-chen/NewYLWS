local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local FixDiv = FixMath.div
local table_insert = table.insert
local table_remove = table.remove
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli
local FixMod = FixMath.mod
local FixRand = BattleRander.Rand
local ACTOR_ATTR = ACTOR_ATTR
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20292 = BaseClass("Skill20292", SkillBase)

function Skill20292:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --1，给随机{A}名己方角色增加{x1}%的攻击速度，持续{B}秒。同时令他们与自身的下一次普攻造成伤害的{C}%转化为生命回复。
    --2，给随机{A}名己方角色增加{x2}%的攻击速度和{y2}%的双攻，持续{B}秒。同时令他们与自身的下一次普攻造成伤害的{C}%转化为生命回复。

    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local battleLogic = CtlBattleInst:GetLogic()
    local teammateList = {}

    ActorManagerInst:Walk(
        function(tmpTarget)
            if battleLogic:IsFriend(performer, tmpTarget, true) then
                table_insert(teammateList, tmpTarget:GetActorID())
            end
        end
    )

    local choiceList = {}
    if self:A() >= #teammateList then
        choiceList = teammateList
    else
        for i = 1, self:A() do
            local index = FixMod(FixRand(), #teammateList)
            index = index + 1
            table_insert(choiceList, teammateList[index])
            table_remove(teammateList, index)
        end
    end

    local atkSpeedPercent = FixDiv(self:X(), 100)
    local atkPercent = FixDiv(self:Y(), 100)

    for _, actorID in ipairs(choiceList) do
        local actor = ActorManagerInst:GetActor(actorID)
        if not actor or not actor:IsLive() then
            return
        end

        local giver = statusGiverNew(performer:GetActorID(), 20292)
        local samanBuff = StatusFactoryInst:NewStatusSaManBuff(giver, 1, FixDiv(self:C(), 100))
        self:AddStatus(performer, actor, samanBuff)

        local giver = statusGiverNew(performer:GetActorID(), 20292)
        local attrBuff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000), {202903})
        attrBuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)

        local curAtkSpeed = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
        local chgAtkSpeed = FixIntMul(curAtkSpeed, atkSpeedPercent)
        attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)

        if self.m_level == 2 then
            local curPhyAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
            local chgPhyAtk = FixIntMul(curPhyAtk, atkPercent)
            attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)

            local curMagicAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
            local chgMagicAtk = FixIntMul(curMagicAtk, atkPercent)
            attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk)
        end
        local succ = self:AddStatus(performer, actor, attrBuff)
    end

end


return Skill20292