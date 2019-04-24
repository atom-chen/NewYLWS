local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local AtkFunc1 = BaseClass("AtkFunc1", SkillBase)
local StatusGiver = StatusGiver
local MediumEnum = MediumEnum
local Formular = Formular
local FixMul = FixMath.mul
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local CtlBattleInst = CtlBattleInst

--物理近程
function AtkFunc1:__init(skill_cfg, level)
end

function AtkFunc1:Perform(performer, target, performPos, special_param)
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
            end
        end
    )
end

return AtkFunc1