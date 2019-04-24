local FixMul = FixMath.mul
local BattleEnum = BattleEnum
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill20024 = BaseClass("Skill20024", AtkFunc1)
local Formular = Formular

function Skill20024:Perform(performer, target, performPos, special_param)
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
          
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
              return  
            end
            
            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = statusGiverNew(performer:GetActorID(), 20024)
                if performer:Get20021Level() >= 2 then 
                    local hurtMul = performer:GetStatusContainer():GetHurtOtherMul(SKILL_TYPE.PHY_ATK)
                    if hurtMul > 0 then -- 伤害加成
                        injure = FixMul(hurtMul, injure)
                    end
                end

                local statusHP = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, statusHP)    
            end
        end
    )
end

return Skill20024