local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local Formular = Formular
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10141 = BaseClass("Skill10141", SkillBase)

function Skill10141:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    -- 血魂枪
    -- 1-2
    -- 夏侯惇对面前扇形范围内的敌人迅速刺出4枪，每一枪造成{x1}（+{E}%物攻)点物理伤害，并附加目标当前生命{A}%的物理伤害。

    -- 3-5
    -- 夏侯惇对面前扇形范围内的敌人迅速刺出4枪，每一枪造成{x3}（+{E}%物攻)点物理伤害，并附加目标当前生命{A}%的物理伤害。技能伤害的{y3}%转化为夏侯惇的生命回复。

    -- 6
    -- 夏侯惇对面前扇形范围内的敌人迅速刺出4枪，每一枪造成{x6}（+{E}%物攻)点物理伤害，并附加目标当前生命{A}%的物理伤害。技能伤害的{y6}%转化为夏侯惇的生命回复。
    -- 如果发动血魂枪时夏侯惇正处于血腥之路护盾中，则血魂枪伤害的{B}%可为护盾充能。

    local logic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local baseHP = 0
    if self.m_level >= 3 then
        baseHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    end
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, performer:GetForward(), nil) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = statusGiverNew(performer:GetActorID(), 10141)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
            end

            local curHP = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            local addInjure = FixIntMul(curHP, FixDiv(self:A(), 100))
            local maxInjure = Formular.CalcMaxHPInjure(self:A(), tmpTarget, BattleEnum.MAXHP_INJURE_PRO_LEFTHP)
            if addInjure > maxInjure then
                addInjure = maxInjure
            end

            local giver = statusGiverNew(performer:GetActorID(), 10141)
            local delayHurtStatus = factory:NewStatusDelayHurt(giver, FixMul(-1, addInjure), BattleEnum.HURTTYPE_REAL_HURT, 500, BattleEnum.HPCHGREASON_BY_SKILL, special_param.keyFrameTimes)
            self:AddStatus(performer, tmpTarget, delayHurtStatus)

            local totalInjure = FixAdd(injure, addInjure)
            if self.m_level >= 3 then
                local recoverHp = FixIntMul(totalInjure, FixDiv(self:Y(), 100))
                local maxRecoverHp = FixIntMul(baseHP, FixDiv(self:C(), 100))
                if recoverHp > maxRecoverHp then
                    recoverHp = maxRecoverHp
                end

                if recoverHp > 0 then
                    local judgeNew = Formular.AtkRoundJudge(performer, performer, BattleEnum.HURTTYPE_PHY_HURT, true)
                    if not Formular.IsJudgeEnd(judgeNew) then
                        local giver = statusGiverNew(performer:GetActorID(), 10141)
                        local status = factory:NewStatusHP(giver, recoverHp, BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judgeNew, special_param.keyFrameTimes)
                        self:AddStatus(performer, performer, status)
                    end
                end
            end

            if self.m_level >= 6 then
                local xiahoudunShield = performer:GetStatusContainer():GetXiahoudunShield()
                if xiahoudunShield then
                    xiahoudunShield:AddHPStore(FixIntMul(totalInjure, FixDiv(self:B(), 100)))
                end
            end
        end
    )
end

return Skill10141