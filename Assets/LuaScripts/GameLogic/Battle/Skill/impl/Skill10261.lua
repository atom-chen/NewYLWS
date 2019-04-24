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
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local FixNormalize = FixMath.Vector3Normalize
local IsInRect = SkillRangeHelper.IsInRect
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10261 = BaseClass("Skill10261", SkillBase)

function Skill10261:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 胡笳吟
    -- 1-2
    -- 蔡文姬对指定区域内的敌人先后发射6道音波，每道音波造成{x1}（+{E}%法攻)点群体法术伤害；被音波命中的敌人定身{B}秒。
    -- 3-5
    -- 蔡文姬对指定区域内的敌人先后发射6道音波，每道音波造成{x3}（+{E}%法攻)点群体法术伤害；被音波命中的敌人定身{B}秒。
    -- 对已被定身的敌人额外造成{y3}（+{E}%法攻)点法术伤害。
    -- 6
    -- 蔡文姬对指定区域内的敌人先后发射6道音波，每道音波造成{x6}（+{E}%法攻)点群体法术伤害；被音波命中的敌人定身{B}秒。
    -- 对已被定身的敌人额外造成{y6}（+{E}%法攻)点法术伤害。每道音波在命中敌人后也能化成和弦反弹给友方单位。

    local battleLogic = CtlBattleInst:GetLogic()
    local normalizedDir = FixNormalize(performPos - performer:GetPosition())
    local performerPos = performer:GetPosition()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local skillLevel = self:GetLevel()
    
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, normalizedDir, performPos) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return
            end

            if self.m_level >= 6 then
                performer:ChordPassiveSkill(tmpTarget)
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
            if injure > 0 then
                local giver = statusGiverNew(performer:GetActorID(), 10261)
                local status = factory:NewStatusHP(giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                        judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
            end

            if skillLevel >= 3 and tmpTarget:GetStatusContainer():IsDingShen() then
                local giver = statusGiverNew(performer:GetActorID(), 10261)
                local injure1 = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:Y())
                local status = factory:NewStatusHP(giver, FixMul(injure1, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                        judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
            end

            local giver = statusGiverNew(performer:GetActorID(), 10261)   
            local dingshenStatus = factory:NewStatusDingShen(giver, FixIntMul(self:B(), 1000))
            self:AddStatus(performer, tmpTarget, dingshenStatus)
        end
    )

    
end

return Skill10261