local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local Formular = Formular


local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill35031 = BaseClass("Skill35031", SkillBase)

function Skill35031:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --白虎召唤万剑打击敌人，对敌方全体造成7段{x1}%的物理伤害，并使其受到的治疗效果减少{A}%，持续{B}秒。

    if special_param.keyFrameTimes == 1 then
        if target and target:IsLive() then
            performer:AddSceneEffect(350303, Vector3.New(target:GetPosition().x, target:GetPosition().y, target:GetPosition().z), Quaternion.Euler(0, -90, 0))
        end
    else
        self:Hurt(performer, special_param)
    end

end

function Skill35031:Hurt(performer, special_param)
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local battleLogic = CtlBattleInst:GetLogic()

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
            
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end
            
            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            local giver = statusGiverNew(performer:GetActorID(), 35031)
            if injure > 0 then
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
            end

            local baihuStatus = factory:NewStatusBaihuDebuff(giver, FixIntMul(self:B(), 1000), FixDiv(self:A(), 100))
            self:AddStatus(performer, tmpTarget, baihuStatus)
        end
    )
end

return Skill35031