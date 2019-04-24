
local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill35015 = BaseClass("Skill35015", AtkFunc1)

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

function Skill35015:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
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
            if not self:InRange(performer, tmpTarget, performer:GetForward(), performer:GetPosition()) then
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

return Skill35015