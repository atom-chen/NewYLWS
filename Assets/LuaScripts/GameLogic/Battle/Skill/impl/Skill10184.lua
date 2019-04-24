local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill10184 = BaseClass("Skill10184", AtkFunc1)

local StatusGiver = StatusGiver
local Formular = Formular
local FixMul = FixMath.mul
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local table_insert = table.insert
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum

function Skill10184:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local enemyTargetIDList = {}
    local enemyHurtList = {}
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
                
                table_insert(enemyTargetIDList, tmpTarget:GetActorID())
                table_insert(enemyHurtList, injure)
            end
        end
    )

    if #enemyTargetIDList > 0 then
        performer:PerformSkill10183(enemyTargetIDList, enemyHurtList)
    end
end

return Skill10184