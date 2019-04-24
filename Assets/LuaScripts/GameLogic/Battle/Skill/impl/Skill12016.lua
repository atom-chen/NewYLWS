local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill12016 = BaseClass("Skill12016", SkillBase)

function Skill12016:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    -- 骁勇长刀 
    -- 挥舞长刀横扫敌人，造成{x1}（+{E}%物攻)点物理伤害，并使敌人陷入虚弱状态：受到伤害增加{D}%，持续{C}秒。
    -- 挥舞长刀横扫敌人，造成{x2}（+{E}%物攻)点物理伤害，并使敌人陷入虚弱状态：受到伤害增加{D}%，持续{C}秒。每当释放本技能时，额外获得{B}点怒气。
    -- 挥舞长刀横扫敌人，造成{x3}（+{E}%物攻)点物理伤害，并使敌人陷入虚弱状态：受到伤害增加{D}%，持续{C}秒。每当释放本技能时，额外获得{B}点怒气。
    -- 挥舞长刀横扫敌人，造成{x4}（+{E}%物攻)点物理伤害，并使敌人陷入虚弱状态：受到伤害增加{D}%，持续{C}秒。每当释放本技能时，额外获得{B}点怒气。
    -- 挥舞长刀横扫敌人，造成{x5}（+{E}%物攻)点物理伤害，并使敌人陷入虚弱状态：受到伤害增加{D}%，持续{C}秒。每当释放本技能时，额外获得{B}点怒气。
    -- 挥舞长刀横扫敌人，造成{x6}（+{E}%物攻)点物理伤害，并使敌人陷入虚弱状态：受到伤害增加{D}%，持续{C}秒。每当释放本技能时，额外获得{B}点怒气。
 
    if self.m_level >= 2 then
        performer:ChangeNuqi(self:B(), BattleEnum.NuqiReason_SKILL_RECOVER, self.m_skillCfg)
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local StatusGiverNew = StatusGiver.New
    local selfPos = performer:GetPosition()
    local perforDir = performer:GetForward()

    local function AddWeakStatus(target)
        local time = FixIntMul(self:C(), 1000)
        local giver = StatusGiverNew(performer:GetActorID(), 12012)
        local statusWeakNew = factory:NewStatusWeak(giver, time)
        self:AddStatus(performer, target, statusWeakNew)

        local giver = StatusGiverNew(performer:GetActorID(), 12012)
        local statusNTimeBeHurtChg = factory:NewStatusNTimeBeHurtMul(giver, time, FixAdd(1, FixDiv(self:D(), 100)))
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_PHY_HURT)
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_REAL_HURT)
        self:AddStatus(performer, target, statusNTimeBeHurtChg)
    end

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, perforDir, performPos) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            local statusWeak = tmpTarget:GetStatusContainer():GetStatusWeak()
            local isFear = tmpTarget:GetStatusContainer():IsFear()
            if (statusWeak or isFear) and performer:RoundJudgeMustBaoji() then
                judge = BattleEnum.ROUNDJUDGE_BAOJI
            end

            if Formular.IsJudgeEnd(judge) then
                return  
            end

            AddWeakStatus(tmpTarget)

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = StatusGiverNew(performer:GetActorID(), 12012)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
            end
        end
    )

end


return Skill12016