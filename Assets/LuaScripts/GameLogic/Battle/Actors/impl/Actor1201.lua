local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local ACTOR_ATTR = ACTOR_ATTR
local FixFloor = FixMath.floor
local FixSub = FixMath.sub

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1201 = BaseClass("Actor1201", Actor)

function Actor1201:__init()
    self.m_12013AHP = 0
    self.m_12013YPercent = 0
    self.m_12013Level = 0
    self.m_12013SkillCfg = nil

    self.m_12017AHP = 0
    
    self.m_12017XHP = 0
    self.m_12017Y = 0
    self.m_12017Level = 0
    self.m_12017SkillCfg = nil

    self.m_12012SkillCfg = nil
    self.m_12012SkillItem = nil

    self.m_baseHP = 0
    self.m_12013XHP = 0
    self.m_12013Active = false
    self.m_12017Active = false
    self.m_chgHP = 0
    self.m_chgValue = 0
end

function Actor1201:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local hpBy100 = FixDiv(self.m_baseHP, 100)

    self.m_12012SkillItem = self.m_skillContainer:GetActiveByID(12012)
    if self.m_12012SkillItem then
        self.m_12012SkillCfg = ConfigUtil.GetSkillCfgByID(12012)
    end

    local skillItem = self.m_skillContainer:GetPassiveByID(12013)
    if skillItem then
        self.m_12013Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(12013)
        self.m_12013SkillCfg = skillCfg
        if skillCfg then
            self.m_12013AHP = FixIntMul(hpBy100, SkillUtil.A(skillCfg, self.m_12013Level))
            self.m_12013XHP = FixIntMul(hpBy100, SkillUtil.X(skillCfg, self.m_12013Level))
            self.m_12013YPercent = FixDiv(SkillUtil.Y(skillCfg, self.m_12013Level), 100)
        end
    end

    local skillItem = self.m_skillContainer:GetPassiveByID(12017)
    if skillItem then
        self.m_12017Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(12017)
        self.m_12017SkillCfg = skillCfg
        if skillCfg then
            self.m_12017AHP = FixIntMul(hpBy100, SkillUtil.A(skillCfg, self.m_12017Level))
            self.m_12017XHP = FixIntMul(hpBy100, SkillUtil.X(skillCfg, self.m_12017Level))
            self.m_12017Y = SkillUtil.Y(skillCfg, self.m_12017Level)
        end
    end
end

function Actor1201:RoundJudgeMustBaoji()
    if self.m_12013SkillCfg then
        return self.m_12013Active and self.m_12013Level >= 6

    elseif self.m_12017SkillCfg then
        return self.m_12017Active and self.m_12017Level >= 6
    end
end

function Actor1201:ChangeHP(giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    Actor.ChangeHP(self, giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    
    if not self:IsLive() then
        return
    end

    local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    if chgVal > 0 and self.m_chgValue > 0 then
        if curHP >= self.m_baseHP then
            self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(self.m_chgValue, -1))
            self.m_chgValue = 0
        end
    end

    if chgVal < 0 and self.m_12013SkillCfg then
        local lastChg = self.m_chgHP 
        self.m_chgHP = FixAdd(self.m_chgHP, FixMul(chgVal, -1))
        
        local count = FixFloor(FixDiv(self.m_chgHP, self.m_12013XHP))
        if count >= 1 then
            if self.m_12012SkillItem and self.m_12012SkillCfg then
                self.m_12012SkillItem:SetLeftCD(0)
            end 

            self.m_chgHP = FixSub(self.m_12013XHP, lastChg)

            if self.m_12013Level >= 4 then
                local chgValue = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_ATK, FixMul(self.m_12013YPercent, count)) 
                self.m_chgValue = FixAdd(self.m_chgValue, chgValue)
                self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgValue)
            end
        end
    end

    if self.m_12013Level >= 6 and self.m_12013SkillCfg then
        if curHP < self.m_12013AHP then
            self.m_12013Active = true
        else
            self.m_12013Active = false
        end
    end

    if chgVal < 0 and self.m_12017SkillCfg then
        local lastChg = self.m_chgHP 
        self.m_chgHP = FixAdd(self.m_chgHP, FixMul(chgVal, -1))

        local count = FixFloor(FixDiv(self.m_chgHP, self.m_12017XHP))
        if count >= 1 then
            if self.m_12012SkillItem and self.m_12012SkillCfg then
                self.m_12012SkillItem:SetLeftCD(0)
            end 

            self.m_chgHP = FixSub(self.m_12017XHP, lastChg)

            if self.m_12017Level >= 4 then
                local chgValue = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_ATK, FixMul(FixDiv(self.m_12017Y, 100), count)) 
                self.m_chgValue = FixAdd(self.m_chgValue, chgValue)
                self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgValue)
            end
        end
    end

    if self.m_12017Level >= 6 and self.m_12017SkillCfg then
        if curHP < self.m_12017AHP then
            self.m_12017Active = true
        else
            self.m_12017Active = false
        end
    end
end

return Actor1201