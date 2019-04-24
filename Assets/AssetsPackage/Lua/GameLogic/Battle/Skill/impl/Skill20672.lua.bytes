local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20672 = BaseClass("Skill20672", SkillBase)

function Skill20672:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    
    -- 铜墙铁壁
    -- 使自身物防增加{x1}%，持续{A}秒。
    -- 使自身物防增加{x2}%，持续{A}秒。同时增加自身{B}%法防。
    local giver = StatusGiver.New(performer:GetActorID(), 20672)
    local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000), {206703})

    local curPhyDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
    local chgPhyDef = FixIntMul(curPhyDef, FixDiv(self:X(), 100))
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
    
    if self.m_level >= 2 then
        local curMagicDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
        local chgMagicDef = FixIntMul(curMagicDef, FixDiv(self:B(), 100))
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, chgMagicDef)
    end

    self:AddStatus(performer, performer,buff)
end

return Skill20672