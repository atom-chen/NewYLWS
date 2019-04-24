local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local ActorManagerInst = ActorManagerInst
local IsInCircle = SkillRangeHelper.IsInCircle
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local StatusGiver = StatusGiver

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1039 = BaseClass("Actor1039", Actor)

function Actor1039:__init()
    self.m_10393SkillCfg = nil
    self.m_10393Level = 0
    self.m_10393A = 0
    self.m_10393B = 0
    self.m_10393X = 0
    self.m_10393Y = 0

    self.m_10397SkillCfg = nil
    self.m_10397Level = 0
    self.m_10397A = 0
    self.m_10397B = 0
    self.m_10397X = 0
    self.m_10397Y = 0

    self.m_gedangSuc = false
    self.m_gedangCount = 0
end


function Actor1039:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    -- 甘宁受到物理伤害时有{x6}%几率发动格挡，免除一半的伤害。每格挡{A}次，将对自身周围一定范围造成{y6}%
    -- 的物理伤害。发动格挡后，甘宁下一次造成伤害时可以偷取受击者{B}点怒气。
    -- todo 考虑怒气 < B

    local skillItem = self.m_skillContainer:GetPassiveByID(10393)
    if skillItem then
        self.m_10393Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10393)
        self.m_10393SkillCfg = skillCfg
        if skillCfg then
            self.m_10393X = SkillUtil.X(skillCfg, self.m_10393Level)

            if self.m_10393Level >= 3 then
                self.m_10393A = SkillUtil.A(skillCfg, self.m_10393Level)
                self.m_10393Y = SkillUtil.Y(skillCfg, self.m_10393Level)

                if self.m_10393Level >= 6 then
                    self.m_10393B = SkillUtil.B(skillCfg, self.m_10393Level)
                end
            end
        end
    end

    local skillItem1 = self.m_skillContainer:GetPassiveByID(10397)
    if skillItem1 then
        self.m_10397Level = skillItem1:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10397)
        self.m_10397SkillCfg = skillCfg
        if skillCfg then
            self.m_10397X = SkillUtil.X(skillCfg, self.m_10397Level)

            if self.m_10397Level >= 3 then
                self.m_10397A = SkillUtil.A(skillCfg, self.m_10397Level)
                self.m_10397Y = SkillUtil.Y(skillCfg, self.m_10397Level)

                if self.m_10397Level >= 6 then
                    self.m_10397B = SkillUtil.B(skillCfg, self.m_10397Level)
                end
            end
        end
    end
end

function Actor1039:PreChgHP(giver, chgHP, hurtType, reason)
    if chgHP >= 0 then
        return chgHP
    end

    chgHP = FixMul(-1, chgHP)

    if hurtType == BattleEnum.HURTTYPE_PHY_HURT then
        if self.m_10393SkillCfg then
            local judge = Formular.GedangJudge(self, self.m_10393X)
            if judge == BattleEnum.ROUNDJUDGE_GEDANG then
                chgHP = FixIntMul(chgHP, 0.5)

                if self.m_10393Level >= 3 then
                    self.m_gedangCount = FixAdd(self.m_gedangCount, 1)
                    if self.m_gedangCount >= self.m_10393A then
                        self.m_gedangCount = 0
                        self:EffectPassive()
                    end

                    if self.m_10393Level >= 6 then
                        self.m_gedangSuc = true
                    end
                end
            end
        end

        if self.m_10397SkillCfg then
            local judge = Formular.GedangJudge(self, self.m_10397X)
            if judge == BattleEnum.ROUNDJUDGE_GEDANG then
                chgHP = FixIntMul(chgHP, 0.5)

                if self.m_10397Level >= 3 then
                    self.m_gedangCount = FixAdd(self.m_gedangCount, 1)
                    if self.m_gedangCount >= self.m_10397A then
                        self.m_gedangCount = 0
                        self:EffectPassive()
                    end

                    if self.m_10397Level >= 6 then
                        self.m_gedangSuc = true
                    end
                end
            end
        end
    end

    return FixMul(-1, chgHP)
end

function Actor1039:EffectPassive()
    local logic = CtlBattleInst:GetLogic()
    local selfPos = self:GetPosition()
    local radius = 3.2
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(selfPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local judge = Formular.AtkRoundJudge(self, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = 0
            local skillID = 0
            if self.m_10393SkillCfg then
                injure = Formular.CalcInjure(self, tmpTarget, self.m_10393SkillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_10393Y)
                skillID = 10393
            elseif self.m_10397SkillCfg then
                injure = Formular.CalcInjure(self, tmpTarget, self.m_10397SkillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_10397Y)
                skillID = 10397
            end

            if injure > 0 then
                local giver = StatusGiver.New(self:GetActorID(), skillID)
                local status = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
                tmpTarget:GetStatusContainer():Add(status, self)
            end
        end
    )
end

function Actor1039:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)

    if self.m_gedangSuc then
        self.m_gedangSuc = false

        if self.m_10393SkillCfg and self.m_10393Level >= 6 then
            self:ChangeNuqi(self.m_10393B, BattleEnum.NuqiReason_SKILL_RECOVER, self.m_10393SkillCfg)
            other:ChangeNuqi(FixMul(self.m_10393B, -1), BattleEnum.NuqiReason_STOLEN, self.m_10393SkillCfg)

        elseif self.m_10397SkillCfg and self.m_10397Level >= 6 then
            self:ChangeNuqi(self.m_10397B, BattleEnum.NuqiReason_SKILL_RECOVER, self.m_10397SkillCfg)
            other:ChangeNuqi(FixMul(self.m_10397B, -1), BattleEnum.NuqiReason_STOLEN, self.m_10397SkillCfg)
        end
    end
end

return Actor1039