local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill10824 = BaseClass("Skill10824", AtkFunc1)

local StatusGiver = StatusGiver
local MediumEnum = MediumEnum
local Formular = Formular
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local CtlBattleInst = CtlBattleInst

function Skill10824:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local hurtMul = performer:Get10823XPercent()
    local selfPhyAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK)
    
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
                if tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK) < selfPhyAtk then
                    injure = FixAdd(injure, FixMul(injure, hurtMul))
                end

                local giver = statusGiverNew(performer:GetActorID(), self.m_skillCfg.id)
                local statusHP = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, statusHP)                
            end
        end
    )
end

return Skill10824