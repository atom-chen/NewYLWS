

local StatusGiver = StatusGiver
local MediumEnum = MediumEnum
local Formular = Formular
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20894 = BaseClass("Skill20894", SkillBase)

function Skill20894:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end

-- "蒋钦每<color=#ffb400>{y1}</color>次普通攻击后，下一次普通攻击伤害增加<color=#ffb400>{x1}%</color>，并且对周围敌人定身<color=#1aee00>{B}</color>秒。",
-- "伤害倍数：提升至<color=#ffb400>{x2}%</color>",
-- "伤害倍数：提升至<color=#ffb400>{x3}%</color>",
-- "伤害倍数：提升至<color=#ffb400>{x4}%</color>\n新效果：所需的攻击次数变为<color=#ffb400>{y4}</color>",

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    
    local chgPercent = performer:GetNextAtkChgPercent()
    local mul = 1

    local isdingshen = false
    if chgPercent > 0 then
        isdingshen = true
        mul = FixAdd(1, FixDiv(chgPercent, 100))
    end

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
            
            performer:ClearNextAtkChgPercent()

            local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = statusGiverNew(performer:GetActorID(), self.m_skillCfg.id)

                injure = FixMul(injure, mul)
              
                local statusHP = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, statusHP)                

                if isdingshen then
                    local dingshenStatus = factory:NewStatusDingShen(giver, FixIntMul(performer:GetDingshenS(), 1000))
                    self:AddStatus(performer, tmpTarget, dingshenStatus)
                end
            end
        end
    )
end


return Skill20894