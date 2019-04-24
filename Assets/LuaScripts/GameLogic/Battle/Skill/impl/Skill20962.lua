local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local CtlBattleInst = CtlBattleInst
local StatusFactoryInst = StatusFactoryInst
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20962 = BaseClass("Skill20962", SkillBase)

function Skill20962:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive()then
        return
    end

    --1,蓄力{A}秒，对当前目标造成{x1}点物理伤害。
    --2,蓄力{A}秒，对当前目标造成{x2}点物理伤害，并击退目标{B}米。

    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local battleLogic = CtlBattleInst:GetLogic()
    
    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end
    
    local giver = statusGiverNew(performer:GetActorID(), 20962)
    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)
    end

    if self.m_level >= 3 then
        target:OnBeatBack(performer, self:B())
    end
end


return Skill20962