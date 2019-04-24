local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local MediumEnum = MediumEnum
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20531 = BaseClass("Skill20531", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill20531:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end

    --举盾格挡，令自身受到的下{x1}次物理伤害强制变为{A}点，同时永久提升自身{y1}%的物防法防。

    local giver = StatusGiver.New(performer:GetActorID(), 20531)
    --FixIntMul(self:A(), -1) 伤害值
    local statusNextNBeHurtChg = StatusFactoryInst:NewStatusNextNBeHurtChg(giver, self:X(), BattleEnum.HURTTYPE_PHY_HURT, FixIntMul(self:A(), -1))
    self:AddStatus(performer, performer, statusNextNBeHurtChg)
   
    local basePhyDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
    local chgPhyDef = FixIntMul(basePhyDef, FixDiv(self:Y(), 100))
    performer:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
    
    local baseMagicDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
    local chgMagicDef = FixIntMul(baseMagicDef, FixDiv(self:Y(), 100))
    performer:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_DEF, chgMagicDef, false)
end


return Skill20531