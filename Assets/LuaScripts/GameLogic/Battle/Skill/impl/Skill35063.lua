local BattleEnum = BattleEnum
local FixMul = FixMath.mul
local ActorManagerInst = ActorManagerInst
local IsInCircle = SkillRangeHelper.IsInCircle
local FixIntMul = FixMath.muli
local Formular = Formular
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill35063 = BaseClass("Skill35063", SkillBase)
function Skill35063:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --低头蓄力{A}秒，期间一团冰云逐渐在敌人头上凝结，蓄力完成后仰天长啸，冰云中降下冰雨，对范围敌人造成{x1}（+{E}%法攻)点法术伤害
    --对没有护盾的敌人造成冰冻{B}秒（先判断冰冻再造成伤害）。

    if special_param.keyFrameTimes == 1 then
        performer:AddSceneEffect(350607, Vector3.New(performPos.x, performPos.y, performPos.z), Quaternion.identity)
    end

    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local battleLogic = CtlBattleInst:GetLogic()
    if special_param.keyFrameTimes == 2 then
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                if not IsInCircle(performPos, self.m_skillCfg.dis2, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                    return
                end

                local giver = statusGiverNew(performer:GetActorID(), 35063)
                local addSuc = false
                if tmpTarget:GetStatusContainer():GetTotalShieldValue() <= 0 then
                    local buff = factory:NewStatusFrozen(giver, FixIntMul(self:B(), 1000))
                    addSuc = self:AddStatus(performer, tmpTarget, buff)
                end
                
                if addSuc then
                    local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
                    if injure > 0 then
                        local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                        self:AddStatus(performer, tmpTarget, status)
                    end
                end
            end
        )
    end

end



return Skill35063