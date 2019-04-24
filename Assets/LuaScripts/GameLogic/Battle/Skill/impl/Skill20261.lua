local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20261 = BaseClass("Skill20261", SkillBase)

function Skill20261:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    -- 蛮王藤甲
    -- 披挂藤甲，令自身受到的物理伤害降低{x1}%、受到的法术伤害提升{y1}%，持续{A}秒。
    -- 披挂藤甲，令自身受到的物理伤害降低{x1}%、受到的法术伤害提升{y1}%，持续{A}秒。
    -- 状态持续期间，回复生命时额外提升{B}%的治疗量。

    --只显示受到伤害降低的飘字

    local time = FixIntMul(self:A(), 1000)
    local giver = StatusGiver.New(performer:GetActorID(), 20261) 
    local statusNTimeBeHurtChg = StatusFactoryInst:NewStatusManwangBuff(giver, time, FixSub(1, FixDiv(self:X(), 100)), {21016})
    statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_PHY_HURT)
    self:AddStatus(performer, target, statusNTimeBeHurtChg)

    local giver = StatusGiver.New(performer:GetActorID(), 20261)
    local statusNTimeBeHurtChg = StatusFactoryInst:NewStatusManwangBuff(giver, time, FixAdd(1, FixDiv(self:Y(), 100)))
    statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)
    self:AddStatus(performer, target, statusNTimeBeHurtChg)

    if self.m_level >= 2 then
        performer:SetRecoverMul(FixDiv(self:B(), 100))
    end
end

function Skill20261:SelectSkillTarget(performer, target)
    return performer, performer:GetPosition()
end

return Skill20261