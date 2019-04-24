local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10473 = BaseClass("Skill10473", SkillBase)

local FixDiv = FixMath.div 
local FixIntMul = FixMath.muli
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local StatusEnum = StatusEnum

function Skill10473:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    -- 当蚀龙护体达到{A}层的瞬间，立即触发僭越称帝效果，令自身在接下来的{B}秒内，
    -- 免疫所有负面状态，全属性提升{x6}%，施加诅咒成功率变为{C}%。僭越称帝每场战斗只能触发一次。
    -- 3、全属性包括：物攻、法攻、物防、法防、命中、闪避、物暴、法暴、暴伤、攻速、移速
    local giver = StatusGiver.New(performer:GetActorID(), 10473)
    local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, FixIntMul(self:A(), 1000))
    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_NEGATIVE)
    immuneBuff:SetCanClearByOther(false)
    self:AddStatus(performer, performer, immuneBuff)

    local data = performer:GetData()
    local attrMul = FixDiv(self:X(), 100)

    local giver = StatusGiver.New(performer:GetActorID(), 10473)
    local buff = StatusFactoryInst:NewStatusYuanshuShilongBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000), {104706})

    local basePhyAtk = data:GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    local chgPhyAtk = FixIntMul(basePhyAtk, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)

    local baseMagicAtk = data:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
    local chgMagicAtk = FixIntMul(baseMagicAtk, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk)

    local basePhyDef = data:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
    local chgPhyDef = FixIntMul(basePhyDef, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)

    local baseMagicDef = data:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
    local chgMagicDef = FixIntMul(baseMagicDef, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, chgMagicDef)
    
    local baseMingzhong = data:GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG)
    local chgMingzhong = FixIntMul(baseMingzhong, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_MINGZHONG, chgMingzhong)

    local baseShanBi = data:GetAttrValue(ACTOR_ATTR.BASE_SHANBI)
    local chgShanBi = FixIntMul(baseShanBi, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_SHANBI, chgShanBi)

    local basePhyBaoji = data:GetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI)
    local chgPhyBaoji = FixIntMul(basePhyBaoji, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_BAOJI, chgPhyBaoji)

    local baseMagicBaoji = data:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI)
    local chgMagicBaoji = FixIntMul(baseMagicBaoji, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_BAOJI, chgMagicBaoji)
    
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_BAOJI_HURT, attrMul)
    
    local curAtkSpeed = data:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
    local chgAtkSpeed = FixIntMul(curAtkSpeed, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)

    local curMoveSpeed = data:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
    local chgMoveSpeed = FixIntMul(curMoveSpeed, attrMul)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_MOVESPEED, chgMoveSpeed)

    self:AddStatus(performer, performer, buff)
end


return Skill10473