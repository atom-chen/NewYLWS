local StatusGiver = StatusGiver
local Formular = Formular
local FixMul = FixMath.mul
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum

local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill10474 = BaseClass("Skill10474", AtkFunc1)

function Skill10474:Perform(performer, target, performPos, special_param)
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
            if IsJudgeEnd(judge) then
              return  
            end
            
            local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = statusGiverNew(performer:GetActorID(), self.m_skillCfg.id)
                local statusHP = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, statusHP)        
                
                if performer:GetCurseAttackCount() > 0 then
                    performer:AtkSBOnce()
                    performer:AddCurse(tmpTarget)
                end
            end
        end
    )
end

return Skill10474