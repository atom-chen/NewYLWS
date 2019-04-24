local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill35062 = BaseClass("Skill35062", SkillBase)

function Skill35062:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --玄武对当前攻击目标发起诅咒，目标受到伤害时，敌方全体都会受到等额伤害，持续{A}秒。

    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local battleLogic = CtlBattleInst:GetLogic()
    
    if not battleLogic:IsEnemy(performer, target, BattleEnum.RelationReason_SKILL_RANGE) then
        return
    end

    local giver = statusGiverNew(performer:GetActorID(), 35062)
    local buff = factory:NewStatusXuanWuCurse(giver, FixIntMul(self:A(), 1000), target:GetActorID())
    self:AddStatus(performer, performer, buff)

end



return Skill35062