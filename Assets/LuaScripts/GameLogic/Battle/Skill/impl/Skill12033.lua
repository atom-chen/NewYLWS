local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill12033 = BaseClass("Skill12033", SkillBase)

local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local StatusEnum = StatusEnum
local FixIntMul = FixMath.muli

function Skill12033:OnFightStart(performer, currWave)
    if not performer or not performer:IsLive() then
        return
    end

--     "廖化在战斗开始的{x1}秒内免疫击退。",
-- "免疫时间提升至{x2}\n新效果：同时免疫击飞",

    local giver = StatusGiver.New(performer:GetActorID(), 12033)
    local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, FixIntMul(self:X(), 1000), {200104})
    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_HURTBACK)

    if self.m_level >= 2 then
        immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_HURTFLY)
    end

    immuneBuff:SetCanClearByOther(false)
    self:AddStatus(performer, performer, immuneBuff)
end

return Skill12033