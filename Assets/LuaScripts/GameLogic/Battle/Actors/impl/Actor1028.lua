local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixSub = FixMath.sub

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1028 = BaseClass("Actor1028", Actor)

function Actor1028:__init()
    self.m_10281Level = 0
    self.m_attrPercent = 0
    self.m_chgPhyAtk = 0
    self.m_chgMagicAtk = 0

    self.m_10283SkillItem = nil
end


function Actor1028:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_10283SkillItem = self.m_skillContainer:GetActiveByID(10283)
end

function Actor1028:Set10281AttrEffect(attrPercent)
    if attrPercent > 0 then
        local chgPhyAtk = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_ATK, attrPercent)
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
        self.m_chgPhyAtk = FixAdd(self.m_chgPhyAtk, chgPhyAtk)

        local chgMagicAtk = self:CalcAttrChgValue(ACTOR_ATTR.BASE_MAGIC_ATK, attrPercent)
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk)
        self.m_chgMagicAtk = FixAdd(self.m_chgMagicAtk, chgMagicAtk)
    end
end


function Actor1028:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    Actor.OnHPChg(self, giver, deltaHP, hurtType, reason, keyFrame)

    local sunquanBuff = self.m_statusContainer:GetSunquanBuff()
    if sunquanBuff and self.m_10283SkillItem then
        local leftCD = self.m_10283SkillItem:GetLeftCD()
        local reducePercent = sunquanBuff:GetSkillReducePercent()
        local chgMS = FixIntMul(leftCD, reducePercent)
        chgMS = FixSub(leftCD, chgMS)

        self.m_10283SkillItem:SetLeftCD(chgMS)
    end
end


function Actor1028:LogicOnFightEnd()
    if self.m_chgPhyAtk > 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(self.m_chgPhyAtk, -1))
        self.m_chgPhyAtk = 0
    end

    if self.m_chgMagicAtk > 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, FixMul(self.m_chgMagicAtk, -1))
        self.m_chgMagicAtk = 0
    end
end


return Actor1028