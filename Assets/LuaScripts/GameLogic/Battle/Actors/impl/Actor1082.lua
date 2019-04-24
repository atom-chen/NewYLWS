local StatusGiver = StatusGiver
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixRand = BattleRander.Rand
local table_remove = table.remove
local table_insert = table.insert
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local CtlBattleInst = CtlBattleInst

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1082 = BaseClass("Actor1082", Actor)

function Actor1082:__init()
    self.m_10823XPercent = 0
    self.m_10823YAtk = 0
    self.m_10823AHP = 0
    self.m_10823B = 0

    self.m_chgPhyAtk = 0

    self.m_baseHP = 0
end


function Actor1082:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local basePhyAtk = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)

    local skillItem = self.m_skillContainer:GetPassiveByID(10823)
    if skillItem then
        self.m_10823Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10823)
        self.m_10823SkillCfg = skillCfg
        if skillCfg then
            self.m_10823XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_10823Level), 100)
            if self.m_10823Level >= 5 then
                self.m_10823AHP = FixIntMul(FixDiv(self.m_baseHP, 100), SkillUtil.A(skillCfg, self.m_10823Level))
                self.m_10823YAtk = FixIntMul(FixDiv(basePhyAtk, 100), SkillUtil.Y(skillCfg, self.m_10823Level))
                self.m_10823B = SkillUtil.B(skillCfg, self.m_10823Level)
            end
        end
    end

    local giver = StatusGiver.New(self:GetActorID(), 10823)
    local huaxiongBuff = StatusFactoryInst:NewStatusHuaxiongBuff(giver, self.m_10823AHP, self.m_10823B)
    self:GetStatusContainer():Add(huaxiongBuff, self)
end

function Actor1082:Get10823XPercent()
    return self.m_10823XPercent
end

function Actor1082:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    Actor.OnHPChg(self, giver, deltaHP, hurtType, reason, keyFrame)

    if self.m_10823Level >= 5 then
        local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        if curHP < self.m_10823AHP and self.m_chgPhyAtk <= 0 then
            self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, self.m_10823YAtk)
            self.m_chgPhyAtk = self.m_10823YAtk

        elseif curHP >= self.m_10823AHP and self.m_chgPhyAtk > 0 then
            self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(self.m_10823YAtk, -1))
            self.m_chgPhyAtk = 0
        end
    end
end

function Actor1082:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end


return Actor1082