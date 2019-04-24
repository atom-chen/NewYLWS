local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20953 = BaseClass("Skill20953", SkillBase)

local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local StatusEnum = StatusEnum
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div

function Skill20953:OnFightStart(performer, currWave)
    if not performer or not performer:IsLive() then
        return
    end

-- "在战斗开始时提升自身<color=#ffb400>{x1}%</color>的物理攻击，持续<color=#1aee00>{A}</color>秒。",
-- "提升的物理攻击增加至<color=#ffb400>{x2}%</color>",
-- "提升的物理攻击增加至<color=#ffb400>{x3}%</color>",
-- "提升的物理攻击增加至<color=#ffb400>{x4}%</color>\n新效果1：额外提升自身的法术攻击<color=#ffb400>{y4}%</color>的",

    local giver = StatusGiver.New(performer:GetActorID(), 20953)
    local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000))
   
    local phyAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    local chgPhyAtk = FixIntMul(phyAtk, FixDiv(self:X(), 100))
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)

    if self:GetLevel() >= 4 then
        local magicAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
        local chgMagicAtk = FixIntMul(magicAtk, FixDiv(self:Y(), 100))
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk)
    end

    self:AddStatus(performer, performer, buff)
end

return Skill20953