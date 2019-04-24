local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local ACTOR_ATTR = ACTOR_ATTR
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusEnum = StatusEnum

local Actor2012 = require "GameLogic.Battle.Actors.impl.Actor2012"
local Actor2086 = BaseClass("Actor2086", Actor2012)

function Actor2086:__init()
    self.m_20863A = 0
    self.m_20863X = 0
    self.m_20863Y = 0
    self.m_20863Level = 0
end

function Actor2086:OnBorn(create_param)
    Actor2012.OnBorn(self, create_param)
    
    local skillItem = self.m_skillContainer:GetPassiveByID(20863)
    if skillItem  then
        local level = skillItem:GetLevel()
        self.m_20863Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(20863)
        self.m_20863SkillCfg = skillCfg
        if skillCfg then
            self.m_20863A = SkillUtil.A(skillCfg, level)
            self.m_20863X = SkillUtil.X(skillCfg, level)
            self.m_20863Y = SkillUtil.Y(skillCfg, level)
        end
    end
end

-- 20863
-- "曹纯每次发动技能后，在<color=#1aee00>{A}</color>秒内免疫控制，且受到所有伤害降低<color=#ffb400>{x1}%</color>。",
-- "受到伤害降低<color=#ffb400>{x2}%</color>",
-- "受到伤害降低<color=#ffb400>{x3}%</color>",
-- "受到伤害降低<color=#ffb400>{x4}%</color>\n新效果：在此期间，曹纯的物攻额外提升<color=#ffb400>{y4}%</color>",

function Actor2086:OnAttackEnd(skillCfg)
    Actor2012.OnAttackEnd(self, skillCfg)

    if skillCfg and not SkillUtil.IsAtk(skillCfg) then
        local time = FixIntMul(self.m_20863A, 1000)
        local giver = StatusGiver.New(self:GetActorID(), 20863)
        local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, time)
        immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
        self.m_statusContainer:Add(immuneBuff)

        local statusNTimeBeHurtChg = StatusFactoryInst:NewStatusNTimeBeHurtMul(giver, time, FixSub(1, FixDiv(self.m_20863X, 100)), {201205})
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_PHY_HURT)
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_REAL_HURT)
        self.m_statusContainer:Add(statusNTimeBeHurtChg)

        if self.m_20863Level >= 4 then
            local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, self.m_20863A)    
            local curAtk = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
            local chgAtk = FixIntMul(curAtk, FixDiv(self.m_20863Y, 100))
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgAtk)
            self.m_statusContainer:Add(buff)
        end
    end
end

return Actor2086