local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local ConfigUtil = ConfigUtil
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local BattleEnum = BattleEnum
local SkillUtil = SkillUtil
local StatusFactoryInst = StatusFactoryInst
local StatusGiver = StatusGiver
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1014 = BaseClass("Actor1014", Actor)

function Actor1014:__init()
    self.m_originalPos = nil
    self.m_addBloodShield = false
    self.m_addBloodPercent = 0
    self.m_bloodShield = 0

    self.m_10143APercent = 0
    self.m_10143XPercent = 0
    self.m_10143B = 0
    self.m_skill10143Cfg = nil
    self.m_skill10143Item = nil
    self.m_skill10143Level = 0
    
    self.m_10147APercent = 0
    self.m_10147XPercent = 0
    self.m_10147B = 0
    self.m_skill10147Cfg = nil
    self.m_skill10147Item = nil
    self.m_skill10147Level = 0

    self.m_10142SkillItem = nil
    self.m_10142SkillCfg = nil
end

function Actor1014:BeginAddBloodShield(percent)
    self.m_addBloodPercent = percent
    self.m_addBloodShield = true
end

function Actor1014:EndAddBloodShield()
    self.m_addBloodPercent = 0
    self.m_addBloodShield = false

    if self.m_bloodShield > 0 then
        local giver = StatusGiver.New(self:GetActorID(), 10142)  
        local status = StatusFactoryInst:NewStatusDelayHurt(giver, FixIntMul(self.m_bloodShield, 1), BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
        self:GetStatusContainer():Add(status, self)
    end

    self.m_bloodShield = 0
end

function Actor1014:SetOriginalPos(pos)
    self.m_originalPos = pos
end

function Actor1014:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_10142SkillItem = self.m_skillContainer:GetActiveByID(10142)
    if self.m_10142SkillItem then
        self.m_10142SkillCfg = ConfigUtil.GetSkillCfgByID(10142)
    end

    self.m_skill10143Item = self.m_skillContainer:GetPassiveByID(10143)
    if self.m_skill10143Item  then
        local level = self.m_skill10143Item:GetLevel()
        self.m_skill10143Level = level
        self.m_skill10143Cfg = ConfigUtil.GetSkillCfgByID(10143)
        if self.m_skill10143Cfg then
            self.m_10143APercent = FixDiv(SkillUtil.A(self.m_skill10143Cfg, level), 100)
            self.m_10143XPercent = FixDiv(SkillUtil.X(self.m_skill10143Cfg, level), 100)
            if level >= 4 then
                self.m_10143B = SkillUtil.B(self.m_skill10143Cfg, level)
            end
        end
    end

    self.m_skill10147Item = self.m_skillContainer:GetPassiveByID(10147)
    if self.m_skill10147Item  then
        local level = self.m_skill10147Item:GetLevel()
        self.m_skill10147Level = level
        self.m_skill10147Cfg = ConfigUtil.GetSkillCfgByID(10147)
        if self.m_skill10147Cfg then
            self.m_10147APercent = FixDiv(SkillUtil.A(self.m_skill10147Cfg, level), 100)
            self.m_10147XPercent = FixDiv(SkillUtil.X(self.m_skill10147Cfg, level), 100)
            if level >= 4 then
                self.m_10147B = FixIntMul(SkillUtil.B(self.m_skill10147Cfg, level), 1000)
            end
        end
    end
end

function Actor1014:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)

    if self.m_addBloodShield then
        self.m_bloodShield = FixAdd(self.m_bloodShield, FixMul(self.m_addBloodPercent, FixMul(chgVal, -1)))
    end
end

function Actor1014:ChangeHP(giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    Actor.ChangeHP(self, giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)

    if self.m_skill10143Cfg and self.m_skill10143Item and chgVal < 0 and self:IsLive() then
        local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local tmpChgHP = FixMul(chgVal, -1)
        local curHPPercent = FixDiv(tmpChgHP, curHP)
        if curHPPercent >= self.m_10143APercent then
            self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_BAOJI_HURT, self.m_10143XPercent)

            if self.m_skill10143Level >= 4 then
                if self.m_10142SkillItem and self.m_10142SkillCfg then
                    local leftCD = self.m_10142SkillItem:GetLeftCD()
                    local cooldown = self.m_10142SkillCfg.cooldown
                    local reduceCD = self:CheckSkillCD(cooldown, self.m_10143B)
                    self.m_10142SkillItem:SetLeftCD(FixSub(leftCD, FixIntMul(reduceCD, 1000)))
                end
            end
        end
    end

    if self.m_skill10147Cfg and self.m_skill10147Item and chgVal < 0 and self:IsLive() then
        local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local tmpChgHP = FixMul(chgVal, -1)
        local curHPPercent = FixDiv(tmpChgHP, curHP)
        if curHPPercent >= self.m_10147APercent then
            self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_BAOJI_HURT, self.m_10147XPercent)

            if self.m_skill10147Level >= 4 then
                if self.m_10142SkillItem and self.m_10142SkillCfg then
                    local leftCD = self.m_10142SkillItem:GetLeftCD()
                    local cooldown = self.m_10142SkillCfg.cooldown
                    local reduceCD = self:CheckSkillCD(cooldown, self.m_10147B)
                    self.m_10142SkillItem:SetLeftCD(FixSub(leftCD, FixIntMul(reduceCD, 1000)))
                end
            end
        end
    end
end

return Actor1014