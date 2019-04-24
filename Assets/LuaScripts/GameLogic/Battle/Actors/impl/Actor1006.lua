local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1006 = BaseClass("Actor1006", Actor)

function Actor1006:__init()
    self.m_10063SkillCfg = 0
    self.m_10063XPercent = 0
    self.m_10063YPercent = 0

    self.m_shouldReset10062CD = false
    self.m_10062SkillItem = false
    self.m_atkCount = 0
    self.m_atkTotalCount = 0
    self.m_10063BaojiAttr = false

    self.m_mingzhongChg = 0
    self.m_baojiHurtChg = 0
end

function Actor1006:AddAttrValue(percent)
    local selfData = self:GetData()
    selfData:AddFightAttr(ACTOR_ATTR.MINGZHONG_PROB_CHG, percent)
    self.m_mingzhongChg = percent

    selfData:AddFightAttr(ACTOR_ATTR.FIGHT_BAOJI_HURT, percent)
    self.m_baojiHurtChg = FixAdd(self.m_baojiHurtChg, percent)
end


function Actor1006:LogicOnFightEnd()
    local selfData = self:GetData()

    if self.m_mingzhongChg > 0 then
        selfData:AddFightAttr(ACTOR_ATTR.MINGZHONG_PROB_CHG, FixMul(self.m_mingzhongChg, -1))
        self.m_mingzhongChg = 0
    end

    if self.m_baojiHurtChg > 0 then
        selfData:AddFightAttr(ACTOR_ATTR.FIGHT_BAOJI_HURT, FixMul(self.m_baojiHurtChg, -1))
        self.m_baojiHurtChg = 0
    end
end


function Actor1006:ShouldResetSkill10062CD()
    self.m_shouldReset10062CD = true
end


function Actor1006:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_10062SkillItem = self.m_skillContainer:GetActiveByID(10062)

    local skill10063Item = self.m_skillContainer:GetPassiveByID(10063)
    if skill10063Item then
        self.m_10063SkillCfg = ConfigUtil.GetSkillCfgByID(10063)
        local level = skill10063Item:GetLevel()
        if self.m_10063SkillCfg then
            self.m_10063XPercent = FixDiv(SkillUtil.X(self.m_10063SkillCfg, level), 100)
            self.m_10063YPercent = FixDiv(SkillUtil.Y(self.m_10063SkillCfg, level), 100)
        end
    end
end


function Actor1006:LogicUpdate(deltaMS)
    if self.m_shouldReset10062CD then
        self:Reset10062CD()
    end
end

function Actor1006:Reset10062CD()
    self.m_shouldReset10062CD = false
    if self.m_10062SkillItem then
        self.m_10062SkillItem:SetLeftCD(0)
    end
end

function Actor1006:ContinueAtk()
    self.m_atkCount = FixAdd(self.m_atkCount, 1)
    local count = 0
    if self.m_atkCount >= 2 then
        count = self.m_atkCount
    end
    self:ShowSkillMaskMsg(count, BattleEnum.SKILL_MASK_HUANGZHONG, TheGameIds.BattleBuffMaskGreen)
    
    if self.m_atkCount >= 2 then
        if not self.m_10063BaojiAttr then
            self.m_10063BaojiAttr = true
        end
    end
end

function Actor1006:InterrupteAtk()
    self.m_atkCount = 0
    self.m_10063BaojiAttr = false
end

function Actor1006:Get10063AtkCount()
    if self.m_atkCount <= 1 then
        return 0
    end        
    return self.m_atkCount
end

function Actor1006:Get10063BaojiAttr()
    local t = self.m_10063BaojiAttr
    if t then
        self.m_10063BaojiAttr = false
    end

    return t
end

function Actor1006:ReduceSBShanbi(target)
    if not self.m_10063SkillCfg or not target or not target:IsLive() and self.m_atkCount >= 2 then
        return
    end

    target:GetData():AddFightAttr(ACTOR_ATTR.SNAHBI_PROB_CHG, FixMul(self.m_10063XPercent, -1))

    self.m_atkTotalCount = FixAdd(self.m_atkTotalCount, 1)
end

function Actor1006:GetAtkHurtMul()
    local curHurtMul = 0
    curHurtMul = FixMul(self.m_10063YPercent, self.m_atkTotalCount)
    return curHurtMul
end

return Actor1006