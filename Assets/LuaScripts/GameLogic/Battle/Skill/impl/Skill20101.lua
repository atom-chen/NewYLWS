local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20101 = BaseClass("Skill20101", SkillBase)

function Skill20101:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- 原地挥动板斧三次，每次造成{X1}（+{e}%攻击力）点范围物理伤害。	
    -- 原地挥动板斧三次，每次造成{X2}（+{e}%攻击力）点范围物理伤害。最后一击可将敌人击退	
    -- 原地挥动板斧三次，每次造成{X2}（+{e}%攻击力）点范围物理伤害。最后一击可将敌人击退
    -- 原地挥动板斧三次，每次造成{X3}（+{e}%攻击力）点范围物理伤害。最后一击可将敌人击退。

    local factory = StatusFactoryInst
    local ctlBattle = CtlBattleInst
    local statusGiverNew = StatusGiver.New
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, performPos, performPos) then
                return
            end

            local judge = AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if IsJudgeEnd(judge) then
              return  
            end

            local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = statusGiverNew(performer:GetActorID(), 20101)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
                
                if self.m_level >= 2 then
                    if special_param.keyFrameTimes == 3 then
                        tmpTarget:OnBeatBack(performer, self.m_skillCfg.hurtbackdis)
                    end
                end
            end
        end
    )
end

return Skill20101