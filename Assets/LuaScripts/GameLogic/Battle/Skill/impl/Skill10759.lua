local StatusGiver = StatusGiver
local Formular = Formular
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10759 = BaseClass("Skill10759", SkillBase)

function Skill10759:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    
    local canrenStatus = performer:GetStatusContainer():HasYanliangCanren() 
    local performerPhyDef = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)
    ActorManagerInst:Walk(
        function(tmpTarget)       
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
           
            if not self:InRange(performer, tmpTarget, performPos, performer:GetPosition()) then
                return
            end
          
            local factor = nil
            local tmpTargetPhyDef = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)
            if performerPhyDef > tmpTargetPhyDef then
                factor = Factor.New()
                factor.phyBaojiProbAdd = performer:Get10753X()
            end

            local judge = AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true, factor)
            if IsJudgeEnd(judge) then
                return  
            end
            
            local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                if canrenStatus then
                    local tmpTargetShield = tmpTarget:GetStatusContainer():GetTotalShieldValue()
                    if tmpTargetShield > 0 then
                        injure = FixAdd(injure, FixIntMul(injure, performer:Get10753Y()))
                    end
                end

                local giver = statusGiverNew(performer:GetActorID(), self.m_skillCfg.id)
                local statusHP = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, statusHP)                
            end
        end
    )
end

return Skill10759