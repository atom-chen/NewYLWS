local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local FixIntMul = FixMath.muli
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill35021 = BaseClass("Skill35021", SkillBase)

function Skill35021:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --朱雀把头部扬起，拍打翅膀蓄力后一口巨大的火焰喷出，造成{x1}（+{E}%法攻)点范围法术伤害

    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end
            
            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
            if injure > 0 then
                local giver = statusGiverNew(performer:GetActorID(), 35021)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
            end

        end
    )

            
end

return Skill35021