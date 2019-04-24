
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixMul = FixMath.mul
local FixSub = FixMath.sub

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20902 = BaseClass("Skill20902", SkillBase)

function Skill20902:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then 
        return 
    end 
    
    --对当前攻击目标施放诅咒，每秒造成{x1}%的法术伤害，持续{A}秒。
    --对当前攻击目标施放诅咒，每秒造成{x2}%的法术伤害，持续{A}秒，并使其造成的伤害降低{y2}%。
    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local giver = StatusGiver.New(performer:GetActorID(), 20902)
    local curseBuff = StatusFactoryInst:NewStatusXuanWuCurse(giver, FixIntMul(self:A(), 1000), target:GetActorID(), {201405})
    self:AddStatus(performer, target, curseBuff)

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 20902)
        local intervalHpStatus = StatusFactoryInst:NewStatusIntervalHP(giver, FixMul(-1, injure), 1000, self:A(), nil, nil, BattleEnum.HURTTYPE_MAGIC_HURT)
        self:AddStatus(performer, target, intervalHpStatus)
    end
 
    if self.m_level >= 3 then
        local hurtMul = FixSub(1, FixDiv(self:Y(), 100))
        local hurtTypeList = {
            {hurtType = BattleEnum.HURTTYPE_MAGIC_HURT, hurtPercent = hurtMul},
            {hurtType = BattleEnum.HURTTYPE_REAL_HURT, hurtPercent = hurtMul},
            {hurtType = BattleEnum.HURTTYPE_PHY_HURT, hurtPercent = hurtMul},
        }
        local giver = StatusGiver.New(performer:GetActorID(), 20902)
        local statusHurtOtherMul = StatusFactoryInst:NewStatusNTimeHurtOtherMul(giver, FixMul(self:A(), 1000), hurtTypeList)       
        self:AddStatus(performer, target, statusHurtOtherMul)
    end
end

return Skill20902