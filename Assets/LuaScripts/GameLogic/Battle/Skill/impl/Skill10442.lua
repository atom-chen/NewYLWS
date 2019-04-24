local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local FixMul = FixMath.mul
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local FixRand = BattleRander.Rand
local table_insert = table.insert
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10442 = BaseClass("Skill10442", SkillBase)

function Skill10442:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    -- 1-3
    -- 张角召唤1道天雷，对当前目标造成{x1}（+{E}%法攻)点法术伤害。天雷有{A}%的几率连续攻击随机1个敌方单位。最多连续攻击{C}次

    -- 4-6
    -- 张角召唤1道天雷，对当前目标造成{x4}（+{E}%法攻)点法术伤害，天雷有{A}%的几率连续攻击随机1个敌方单位。最多连续攻击{C}次
    -- 被天雷击中的敌方单位会陷入虚弱状态，己方对其造成的伤害额外提升{y4}%，持续{B}秒。
    local function AddBeHurtMulBuff(target)
        local giver = StatusGiver.New(performer:GetActorID(), 10442)
        local statusNTimeBeHurtChg = StatusFactoryInst:NewStatusNTimeBeHurtMul(giver, FixIntMul(self:B(), 1000), FixAdd(1, FixDiv(self:Y(), 100)), {21015})
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_PHY_HURT)
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_REAL_HURT)

        self:AddStatus(performer, target, statusNTimeBeHurtChg)
    end

    target:AddEffect(104405)

    local judge = AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if IsJudgeEnd(judge) then
        return  
    end

    local injure = CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 10442)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)
        if self.m_level >= 4 then
            AddBeHurtMulBuff(target)
        end

        for count = 1, self:C() do
            local randVal = FixMod(FixRand(), 100)
            if randVal < self:A() then
                local randActor = self:RandEnemyActor(performer)
                if randActor and randActor:IsLive() then
                    local giver = StatusGiver.New(performer:GetActorID(), 10442)
                    local delayHurtStatus = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, FixMul(count, 500), BattleEnum.HPCHGREASON_BY_SKILL, special_param.keyFrameTimes)
                    self:AddStatus(performer, randActor, delayHurtStatus)

                    if self.m_level >= 4 then
                        AddBeHurtMulBuff(randActor)
                    end
                end
            else
                break
            end
        end
    end
end

function Skill10442:RandEnemyActor(performer)
    local enemyList = {}
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            table_insert(enemyList, tmpTarget)
        end
    )

    local count = #enemyList
    local tmpActor = false
    if count > 0 then
        local index = FixMod(BattleRander.Rand(), count)
        index = FixAdd(index, 1)
        tmpActor = enemyList[index]
        if tmpActor then
            return tmpActor
        end
    end

    return false
end

return Skill10442