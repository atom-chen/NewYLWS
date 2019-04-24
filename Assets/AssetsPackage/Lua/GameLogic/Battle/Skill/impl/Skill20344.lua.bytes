local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20344 = BaseClass("Skill20344", SkillBase)

function Skill20344:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.ROUNDJUDGE_NORMAL, self:X())
            if injure > 0 then
                local giver = StatusGiver.New(performer:GetActorID(), 20344)   
                
                local statusHp = StatusFactoryInst:NewStatusHP(giver,  FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, 
                BattleEnum.HPCHGREASON_BY_ATTACK, BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, statusHp)
            end
        end
    )
end

return Skill20344