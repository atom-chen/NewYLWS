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
local Skill20662 = BaseClass("Skill20662", SkillBase)

function Skill20662:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    
    -- 狂乱
    -- 提升{x1}%攻击速度，持续{A}秒。
    -- 提升{x2}%攻击速度，持续{A}秒。同时提升物理攻击力{B}%。
    local giver = StatusGiver.New(performer:GetActorID(), 20662)
    local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000))

    local curAtkSpeed = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
    local chgAtkSpeed = FixIntMul(curAtkSpeed, FixDiv(self:X(), 100))
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
    
    if self.m_level >= 2 then
        local curPhyAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
        local chgPhyAtk = FixIntMul(curPhyAtk, FixDiv(self:B(), 100))
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
    end

    self:AddStatus(performer, performer,buff)
end

return Skill20662