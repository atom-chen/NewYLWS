local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local Formular = Formular
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10091 = BaseClass("Skill10091", SkillBase)

function Skill10091:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    
    -- 傲骨狂心
    -- 1
    -- 魏延将短戟插入地面，蓄力{A}秒后拔出并向前挥砍，将范围内的敌人全部震退{B}米并造成{x1}（+{E}%物攻)点物理伤害。蓄力期间魏延免疫一切控制状态。
    -- 2-4
    -- 魏延将短戟插入地面，蓄力{A}秒后拔出并向前挥砍，将范围内的敌人全部震退{B}米并造成{x2}（+{E}%物攻)点物理伤害，并附加魏延已损生命{y2}%的真实伤害。
    -- 蓄力期间魏延免疫一切控制状态。
    -- 5-6
    -- 魏延将短戟插入地面，蓄力{A}秒后拔出并向前挥砍，将范围内的敌人全部震退{B}米并造成{x5}（+{E}%物攻)点物理伤害，并附加魏延已损生命{y5}%的真实伤害。
    -- 蓄力期间魏延免疫一切控制状态，受到所有伤害降低{z5}%。

    if special_param.keyFrameTimes == 1 then
        local time = FixIntMul(self:A(), 1000)
        local giver = StatusGiver.New(performer:GetActorID(), 10091)
        local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, time)
        immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
        self:AddStatus(performer, performer, immuneBuff)

        if self.m_level >= 5 then
            local giver = StatusGiver.New(performer:GetActorID(), 10091)
            local statusNTimeBeHurtChg = StatusFactoryInst:NewStatusNTimeBeHurtMul(giver, time, FixSub(1, FixDiv(self:Z(), 100)))
            statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_PHY_HURT)
            statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)
            self:AddStatus(performer, performer, statusNTimeBeHurtChg)
        end
    else
        local battleLogic = CtlBattleInst:GetLogic()
        local statusGiverNew = StatusGiver.New
        local performDir = performer:GetForward()
        local baseHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
        local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local chgHP = FixSub(baseHP, curHP)
        local maxInjure = Formular.CalcMaxHPInjure(self:Y(), performer, BattleEnum.MAXHP_INJURE_PRO_LOSTHP)
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not self:InRange(performer, tmpTarget, performDir, nil) then
                    return
                end

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then
                    local giver = statusGiverNew(performer:GetActorID(), 10091)
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                        judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, tmpTarget, status)

                    tmpTarget:OnBeatBack(performer, self:B())

                    if self.m_level >= 2 and chgHP > 0 then
                        local extralHP = FixMul(chgHP, FixDiv(self:Y(), 100))
                        if extralHP > maxInjure then
                            extralHP = maxInjure 
                        end

                        local giver = statusGiverNew(performer:GetActorID(), 10091)
                        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(extralHP, -1), BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                        self:AddStatus(performer, tmpTarget, status)
                    end
                end
            end
        )
    end
end

return Skill10091