local StatusGiver = StatusGiver
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local ACTOR_ATTR = ACTOR_ATTR
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10761 = BaseClass("Skill10761", SkillBase)

function Skill10761:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then 
        return 
    end

    -- 饥渴之盾  1 
    -- 文丑失去{x1}%的双防，按损失防御量的{A}%削弱技能范围内敌人的双防。持续{B}秒。
    -- 2-4
    -- 文丑失去{x4}%的双防，按损失防御量的{A}%削弱技能范围内敌人的双防，并且自身附带{y4}%的伤害反弹效果。持续{B}秒。
    -- 5-6
    -- 文丑失去{x6}%的双防，按损失防御量的{A}%削弱技能范围内敌人的双防，削弱的双防将转化为己方全体角色同等数值的双暴。
    -- 且自身附带{y6}%的伤害反弹效果。持续{B}秒。
    local time = FixIntMul(self:B(), 1000)
    local StatusGiverNew = StatusGiver.New
    local factory = StatusFactoryInst
    local chgDefPercent = FixDiv(self:X(), 100)
    local enemyChgDefPercent = FixDiv(self:A(), 100)

    local giver = StatusGiverNew(performer:GetActorID(), 10761)
    local attrBuff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time)
    attrBuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)

    local curPhyDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
    local chgPhyDef = FixMul(curPhyDef, chgDefPercent)
    attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixIntMul(chgPhyDef, -1))

    local curMagicDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
    local chgMagicDef = FixMul(curMagicDef, chgDefPercent)
    attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, FixIntMul(chgMagicDef, -1))

    self:AddStatus(performer, performer, attrBuff)

    if self.m_level >= 2 then
        local giver = StatusGiverNew(performer:GetActorID(), 10761)
        local fantanStatus = factory:NewStatusFanTan(giver, time, FixDiv(self:Y(), 100))
        self:AddStatus(performer, performer, fantanStatus)
    end

    local radius = self.m_skillCfg.dis2
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if battleLogic:IsFriend(performer, tmpTarget, true) then
                if self.m_level >= 5 then
                    local giver = StatusGiverNew(performer:GetActorID(), 10761)
                    local attrBuff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time)
                    attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_BAOJI, chgPhyDef)
                    attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_BAOJI, chgMagicDef)
                    self:AddStatus(performer, tmpTarget, attrBuff)
                end

                return
            end

            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end
            
            local giver = StatusGiverNew(performer:GetActorID(), 10761)
            local attrBuff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time)
            attrBuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)

            local tmpChgPhyDef = FixIntMul(chgPhyDef, chgDefPercent)
            attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(tmpChgPhyDef, -1))

            local tmpChgMagicDef = FixIntMul(chgMagicDef, chgDefPercent)
            attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, FixMul(chgMagicDef, -1))
            self:AddStatus(performer, tmpTarget, attrBuff)
        end
    )

end

return Skill10761