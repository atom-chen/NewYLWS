local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local FixIntMul = FixMath.muli

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20851 = BaseClass("Skill20851", SkillBase)

function Skill20851:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    
    -- 水之禁锢
    -- 吟唱{A}秒，禁锢选中目标，每秒造成{x1}%的法术伤害，持续{B}秒。
    -- 吟唱{A}秒，禁锢选中目标，每秒造成{x2}%的法术伤害，持续{B}秒，该效果不可驱散。
    -- 吟唱{A}秒，禁锢选中目标，每秒造成{x3}%的法术伤害，持续{B}秒，该效果不可驱散。
    -- 吟唱{A}秒，禁锢选中目标，每秒造成{x4}%的法术伤害，持续{B}秒，该效果不可驱散。

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    local injureInterval = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
    if injureInterval > 0 then
        local statusGiverNew = StatusGiver.New
        local giver = statusGiverNew(performer:GetActorID(), 20851)
        local intervalStatus = StatusFactoryInst:NewStatusIntervalHP(giver, FixMul(injureInterval, -1), 1000, self:B())
        if self.m_level >= 2 then
            intervalStatus:SetCanClearByOther(false)
        end
        self:AddStatus(performer, target, intervalStatus)

        local giver = statusGiverNew(performer:GetActorID(), 20851)
        local buff = StatusFactoryInst:NewStatusFrozen(giver, FixIntMul(self:B(), 1000), {206904})
        if self.m_level >= 2 then
            buff:SetCanClearByOther(false)
        end
        self:AddStatus(performer, target, buff)
    end
end

return Skill20851