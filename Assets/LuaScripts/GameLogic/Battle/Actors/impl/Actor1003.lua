local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixFloor = FixMath.floor
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1003 = BaseClass("Actor1003", Actor)

function Actor1003:__init()
    self.m_10033Level = 0
    self.m_10033X = 0
    self.m_10033YPercent = 0
    self.m_10033APercent = 0
    self.m_10033BPercent = 0
    self.m_10033C = 0
    self.m_1033XHP = 0

    self.m_baseHP = 0

    self.m_phyAtkChg = 0
    self.m_phyDefChg = 0
    self.m_atkSpeedChg = 0

    self.m_10033Count = 0
    self.m_10033ExtraCount = 0
end

function Actor1003:PreChgHP(giver, chgHP, hurtType, reason)
    if chgHP < 0 then
        local zhangfeiDef = self:GetStatusContainer():GetZhangfeiDef()
        if zhangfeiDef then
            if zhangfeiDef:IsDefHurt(giver.actorID) then
                local hurtDefPercent = zhangfeiDef:GetDefPercent()
                chgHP = FixSub(chgHP, FixIntMul(chgHP, hurtDefPercent))
            end
        end
    end
    return chgHP
end

function Actor1003:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    Actor.OnHPChg(self, giver, deltaHP, hurtType, reason, keyFrame)

    if not self:IsLive() then
        return
    end

    local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local chgHP = FixSub(self.m_baseHP, curHP)

    if chgHP <= 0 then
        self:ReduceAttr()
        return
    end

    if chgHP < self.m_1033XHP then
        return
    end

    local count = FixFloor(FixDiv(chgHP, self.m_1033XHP))
    local chgCount = FixSub(count, self.m_10033Count)
    if chgCount == 0 then
        return
    end
    self.m_10033Count = count
    if chgCount > 0 then
        self:ShowSkillMaskMsg(FixAdd(self.m_10033Count, self.m_10033ExtraCount), BattleEnum.SKILL_MASK_ZHANGFEI, TheGameIds.BattleBuffMaskRed)
    end

    local isShowed = false
    local chgAtkSpeed = FixIntMul(FixMul(count, self.m_10033APercent), self:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED))
    local diffAtkSpeed = FixSub(chgAtkSpeed, self.m_atkSpeedChg)
    if diffAtkSpeed ~= 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, diffAtkSpeed, isShowed)
        self.m_atkSpeedChg = chgAtkSpeed
    end

    local chgPhyAtk = FixIntMul(FixMul(count, self.m_10033BPercent), self:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK))
    local diffPhyAtk = FixSub(chgPhyAtk, self.m_phyAtkChg)
    if diffPhyAtk ~= 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, diffPhyAtk, isShowed)
        self.m_phyAtkChg = chgPhyAtk
    end

    if self.m_10033Level >= 4 then
        local curPhyAtk = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK)
        local chgPhyDef = FixIntMul(FixMul(self.m_10033YPercent, count), curPhyAtk)
        local diffPhyDef = FixSub(chgPhyDef, self.m_phyDefChg)
        if diffPhyDef ~= 0 then
            self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, diffPhyDef, isShowed)
            self.m_phyDefChg = chgPhyDef
        end
    end
end

function Actor1003:LogicOnFightStart(currWave)
    if currWave == 1 and self.m_10033Level == 6 then
        local chgAtkSpeed = FixIntMul(FixMul(self.m_10033C, self.m_10033APercent), self:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED))
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)

        local chgPhyAtk = FixIntMul(FixMul(self.m_10033C, self.m_10033BPercent), self:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK))
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk, false)

        local curPhyAtk = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK)
        local chgPhyDef = FixIntMul(FixDiv(self.m_10033YPercent, 100), curPhyAtk)
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef, false)

        self.m_10033ExtraCount = FixAdd(self.m_10033C, self.m_10033ExtraCount)
        self:ShowSkillMaskMsg(self.m_10033ExtraCount, BattleEnum.SKILL_MASK_ZHANGFEI, TheGameIds.BattleBuffMaskRed)
    end
end

function Actor1003:ReduceAttr()
    if self.m_phyAtkChg > 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(self.m_phyAtkChg, -1))
        self.m_phyAtkChg = 0
    end

    if self.m_phyDefChg > 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(self.m_phyDefChg, -1))
        self.m_phyDefChg = 0
    end

    if self.m_atkSpeedChg > 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, FixMul(self.m_atkSpeedChg, -1))
        self.m_atkSpeedChg = 0
    end
end

function Actor1003:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    -- 被动：死战
    -- 当张飞的生命低于100%时，每降低{X6}%血量，就获得额外{a}%的攻击速度和{b}%的物理攻击加成，并获得相当于当前物攻{Y6}%的物理防御加成，可叠加。
    -- 每场战斗开始时，张飞即可获得{c}层死战加成。

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)

    local skillItem = self.m_skillContainer:GetPassiveByID(10033)
    if skillItem  then
        self.m_10033Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10033)
        if skillCfg then
            self.m_10033APercent = FixDiv(SkillUtil.A(skillCfg, self.m_10033Level), 100)
            self.m_10033BPercent = FixDiv(SkillUtil.B(skillCfg, self.m_10033Level), 100)
            self.m_10033X = SkillUtil.X(skillCfg, self.m_10033Level)
            self.m_1033XHP = FixIntMul(FixDiv(self.m_baseHP, 100), self.m_10033X)
            self.m_10033YPercent = FixDiv(SkillUtil.Y(skillCfg, self.m_10033Level), 100)

            if self.m_10033Level == 6 then
                self.m_10033C = SkillUtil.C(skillCfg, self.m_10033Level)
            end
            
        end
    end
end

function Actor1003:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    if skillCfg.id == 10032 then
        local movehelper = self:GetMoveHelper()
        if movehelper then
            movehelper:Stop()
        end
    end
end


return Actor1003