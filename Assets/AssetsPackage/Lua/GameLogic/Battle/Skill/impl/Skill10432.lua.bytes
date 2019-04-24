local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local Quaternion = Quaternion
local Vector3 = Vector3
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local IsInCircle = SkillRangeHelper.IsInCircle
local BattleCameraMgr = BattleCameraMgr
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10432 = BaseClass("Skill10432", SkillBase)

function Skill10432:Perform(performer, target, performPos, special_param)
    if not performer or not target then
        return
    end

    -- 剑气乱击

    -- 从天而降剑气对目标及其附近{c}米内的敌方武将造成{X1点法术伤害。

    -- 2 - 6
    -- 从天而降剑气对目标及其附近{c}米内的敌方武将造成{X2}（+{e}%法攻)点法术伤害，被命中的敌方武将在{a}秒内受到的所有法术伤害会提升{b}%。

    BattleCameraMgr:Shake()

    performer:AddSceneEffect(104308, Vector3.New(target:GetPosition().x, target:GetPosition().y, target:GetPosition().z), Quaternion.identity)

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local skillLevel = self:GetLevel()
    
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(target:GetPosition(), self:C(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
              return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
            if injure > 0 then
                local giver = StatusGiver.New(performer:GetActorID(), 10432)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)

                if skillLevel >= 2 then
                    local statusNTimeBeHurtChg = StatusFactoryInst:NewStatusNTimeBeHurtMul(giver, FixIntMul(self:A(), 1000), FixAdd(1, FixDiv(self:B(), 100)))
                    statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)
                    self:AddStatus(performer, tmpTarget, statusNTimeBeHurtChg)
                end
            end
        end
    )
end

return Skill10432