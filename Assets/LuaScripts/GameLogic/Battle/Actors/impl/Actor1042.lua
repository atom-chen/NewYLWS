local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1042 = BaseClass("Actor1042", Actor)

function Actor1042:__init()
    self.m_10421MakeHurt = 0
    self.m_1042originalPos = false

    self.m_10423APercent = 0
    self.m_10423D = 0
    self.m_10423B = 0
    self.m_10423SkillCfg = false

    self.m_chgNextAtkPro = false
    self.m_chongGuanIntervalTime = 0
    self.m_chongGuanYiNuPerforming = false

    self.m_chgHP = 0
end

function Actor1042:Add10421MakeHurt(hurt)
    self.m_10421MakeHurt = FixAdd(self.m_10421MakeHurt, hurt)
end

function Actor1042:Get10421MakeHurt()
    return self.m_10421MakeHurt
end

function Actor1042:Clear10421MakeHurt()
    self.m_10421MakeHurt = 0
end

function Actor1042:SetChgNextAtkPro(isChg)
    self.m_chgNextAtkPro = isChg
end

function Actor1042:IsChgNextAtkPro()
    return self.m_chgNextAtkPro
end

function Actor1042:SetOriginalPos(pos)
    self.m_1042originalPos = pos
end

function Actor1042:GetOriginalPos()
    return self.m_1042originalPos
end

function Actor1042:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    Actor.OnHPChg(self, giver, deltaHP, hurtType, reason, keyFrame)

    if deltaHP > 0 then
        return
    end

    self.m_chgHP = FixAdd(self.m_chgHP, FixMul(deltaHP, -1))

    local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    if curHP < 1 then
        curHP = 1
    end

    local chgHPPercent = FixDiv(self.m_chgHP, curHP)
    if self.m_10423SkillCfg and chgHPPercent >= self.m_10423APercent then
        if not self.m_chongGuanYiNuPerforming then
            self.m_chongGuanYiNuPerforming = true
            local selfAI = self:GetAI()
            if selfAI then
                selfAI:EffectPassiveSkill()
            end

            self.m_chgHP = FixSub(self.m_chgHP, FixIntMul(self.m_10423APercent, curHP))
        end
    end
end


function Actor1042:LogicUpdate(deltaMS)
    if self.m_10423SkillCfg and self.m_chongGuanYiNuPerforming then
        self.m_chongGuanIntervalTime = FixAdd(self.m_chongGuanIntervalTime, deltaMS)
        if self.m_chongGuanIntervalTime >= self.m_10423D then
            self.m_chongGuanIntervalTime = 0
            self.m_chongGuanYiNuPerforming = false
            return
        end
    end
end

function Actor1042:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    -- 被动：冲冠一怒
    -- 吕布受到单次伤害超过当前生命{a}%时，就对周围{b}米半径范围内所有敌人造成一次相当于自身已损生命{X3}%的真实伤害，
    -- 并获得{c}点怒气，同时令自己的下次普通攻击必然命中且暴击。

    local skillItem = self.m_skillContainer:GetPassiveByID(10423)
    if skillItem  then
        local skillLevel = skillItem:GetLevel()

        self.m_10423SkillCfg = ConfigUtil.GetSkillCfgByID(10423)
        if self.m_10423SkillCfg then
            self.m_10423APercent = FixDiv(SkillUtil.A(self.m_10423SkillCfg, skillLevel), 100)
            self.m_10423D = FixIntMul(SkillUtil.D(self.m_10423SkillCfg, skillLevel), 1000)
            self.m_10423B = SkillUtil.B(self.m_10423SkillCfg, skillLevel)
        end
    end
end

function Actor1042:GetPassiveB()
    return self.m_10423B
end

function Actor1042:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    if skillCfg.id == 10422 then
        local movehelper = self:GetMoveHelper()
        if movehelper then
            movehelper:Stop()
        end
    end
end

return Actor1042