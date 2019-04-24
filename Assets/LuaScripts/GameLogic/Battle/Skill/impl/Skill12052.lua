local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixDiv = FixMath.div

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill12052 = BaseClass("Skill12052", SkillBase)

function Skill12052:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    
    -- 公孙瓒面对目标将长枪舞动得密不透风，对区域内的敌人造成6次{x1}%的物理伤害。
    -- 公孙瓒面对目标将长枪舞动得密不透风，对区域内的敌人造成6次{x2}%的物理伤害。
    -- 公孙瓒面对目标将长枪舞动得密不透风，对区域内的敌人造成6次{x3}%的物理伤害。
    -- 公孙瓒面对目标将长枪舞动得密不透风，对区域内的敌人造成6次{x4}%的物理伤害。此时公孙瓒受到敌方远程飞行物攻击的伤害降低{y4}%。
    -- 公孙瓒面对目标将长枪舞动得密不透风，对区域内的敌人造成6次{x5}%的物理伤害。此时公孙瓒受到敌方远程飞行物攻击的伤害降低{y5}%。
    -- 公孙瓒面对目标将长枪舞动得密不透风，对区域内的敌人造成6次{x6}%的物理伤害。此时公孙瓒受到敌方远程飞行物攻击的伤害降低{y6}%。
    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local dir = performPos - performer:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, dir, nil) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = StatusGiver.New(performer:GetActorID(), 12052)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
            end
        end
    )

    if self.m_level >= 4 then
        performer:Set12052ReducePercent(FixDiv(self:Y(), 100), self:B())
    end
end


return Skill12052