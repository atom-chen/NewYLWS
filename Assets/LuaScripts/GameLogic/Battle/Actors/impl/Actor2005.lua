local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local BattleEnum = BattleEnum
local SkillUtil = SkillUtil
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2005 = BaseClass("Actor2005", Actor)

function Actor2005:__init()
    self.m_20053SkillCfg = nil
    self.m_20053XPercent = 0
    self.m_20053A = 0
    self.m_20053B = 0
    self.m_20053CPercent = 0
    self.m_20053SkillLevel = 0

    self.m_20052SkillItem = nil
    self.m_20052SkillCfg = nil
    self.m_activePassiveEffect = false
    self.m_continueTime = 0
end

function Actor2005:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_20052SkillItem = self.m_skillContainer:GetActiveByID(20052)
    self.m_20052SkillCfg = ConfigUtil.GetSkillCfgByID(20052)

    local skillItem = self.m_skillContainer:GetPassiveByID(20053)
    if skillItem  then
        local skillLevel = skillItem:GetLevel()
        self.m_20053SkillLevel = skillLevel
        self.m_20053SkillCfg = ConfigUtil.GetSkillCfgByID(20053)
        if self.m_20053SkillCfg then
            self.m_20053A = FixIntMul(SkillUtil.A(self.m_20053SkillCfg, skillLevel), 1000)
            self.m_20053XPercent = FixDiv(SkillUtil.X(self.m_20053SkillCfg, skillLevel), 100)
            self.m_20053CPercent = FixDiv(SkillUtil.C(self.m_20053SkillCfg, skillLevel), 100)
            if skillLevel >= 4 then
                self.m_20053B = SkillUtil.B(self.m_20053SkillCfg, skillLevel)
            end
        end
    end
end

function Actor2005:AddPassiveAttr()
    if not self.m_20053SkillCfg then
        return
    end

    local giver = StatusGiver.New(self:GetActorID(), 20053)
    local buff = StatusFactoryInst:NewStatusGuanhaiBuff(giver, BattleEnum.AttrReason_SKILL, self.m_20053A)

    local chgAtk = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_ATK, self.m_20053XPercent)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgAtk)
    local chgAtkSpeed = self:CalcAttrChgValue(ACTOR_ATTR.BASE_ATKSPEED, self.m_20053CPercent)
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
    buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)

    self:GetStatusContainer():DelayAdd(buff)
end


function Actor2005:IsActivePassiveEffect()
    return self.m_20053SkillLevel >= 4
end

function Actor2005:ActivePassiveSkill()
    self.m_continueTime = self.m_20053A
end

function Actor2005:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    if skillCfg.id == 20052 then
        -- 被动 level 4 此时每次攻击命中，都可削减太平道法{b}秒的冷却时间。
        if not self.m_activePassiveEffect and self.m_20053SkillLevel >= 4 then
            self.m_activePassiveEffect = true
        end
    end
end

function Actor2005:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)

    if self.m_continueTime > 0 and self.m_activePassiveEffect then
        self:Reduce20052()
    end
end

function Actor2005:Reduce20052()
	-- 被动效果
    if not self.m_20053SkillCfg or not self.m_20052SkillItem or not self.m_20052SkillCfg then
        return
    end

    local leftCD = self.m_20052SkillItem:GetLeftCD()
    local cooldown = self.m_20052SkillCfg.cooldown
    local reduceCD = self:CheckSkillCD(cooldown, self.m_20053B)
    self.m_20052SkillItem:SetLeftCD(FixSub(leftCD, FixIntMul(reduceCD, 1000)))
end

function Actor2005:LogicUpdate(deltaMS)
    if self.m_activePassiveEffect and self.m_continueTime > 0 then
        self.m_continueTime = FixSub(self.m_continueTime, deltaMS)
        if self.m_continueTime <= 0 then
            self.m_activePassiveEffect = false
        end
    end
end


return Actor2005