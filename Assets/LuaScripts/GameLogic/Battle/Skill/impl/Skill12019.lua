local StatusGiver = StatusGiver
local Formular = Formular
local FixMul = FixMath.mul
local AtkRoundJudge = Formular.AtkRoundJudge
local ActorManagerInst = ActorManagerInst
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum

local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill12019 = BaseClass("Skill12019", AtkFunc1)

function Skill12019:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    
    ActorManagerInst:Walk(
        function(tmpTarget)       
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
           
            if not self:InRange(performer, tmpTarget, performPos, performer:GetPosition()) then
                return
            end
          
            local judge = AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            local statusWeak = tmpTarget:GetStatusContainer():GetStatusWeak()
            local isFear = tmpTarget:GetStatusContainer():IsFear()
            if (statusWeak or isFear) and performer:RoundJudgeMustBaoji() then
                judge = BattleEnum.ROUNDJUDGE_BAOJI
            end

            if IsJudgeEnd(judge) then
                return  
            end
            
            local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = statusGiverNew(performer:GetActorID(), self.m_skillCfg.id)
                local statusHP = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, statusHP)                
            end
        end
    )
end

return Skill12019