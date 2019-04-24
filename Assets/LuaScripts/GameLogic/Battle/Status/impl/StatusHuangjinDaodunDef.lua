local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixFloor = FixMath.floor

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusHuangjinDaodunDef = BaseClass("StatusHuangjinDaodunDef", StatusBase)

-- leftCount  表示下次攻击伤害加成次数
-- isDefensiveState 表示是不是防御姿态
-- leftCount > 0 isDefensiveState = false 表示防御姿态解除，下次普攻未进行加成


function StatusHuangjinDaodunDef:__init()
    self.m_giver = false  
    self.m_atkHurMul = 0
    self.m_hurtDefPercent = 0
    self.m_maxAtkHurtMul = 0
    self.m_statusKeepTime = 0
    self.m_isDefensiveState = true
    self.m_leftMS = 0
    self.m_leftCount = 1

    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT

    self.m_effectKey = 0
end

function StatusHuangjinDaodunDef:Init(giver, leftMS, hurtDefPercent, maxHurtPercent, atkHurtMul, effect)
    self.m_giver = giver
    self.m_atkHurMul = atkHurtMul or 1
    self.m_hurtDefPercent = hurtDefPercent
    self.m_maxAtkHurtMul = maxHurtPercent
    self.m_isDefensiveState = true
    self:SetLeftMS(leftMS)
    -- self.m_leftMS = leftMS
    self.m_leftCount = 1
    self.m_statusKeepTime = 0

    self.m_effectMask = effect
    self.m_effectKey = 0
end

function StatusHuangjinDaodunDef:GetStatusType()
    return StatusEnum.STATUSTYPE_HUANGJINDAODUN_DEFENSIVESTATE
end

function StatusHuangjinDaodunDef:IsDefensiveState()
    return self.m_isDefensiveState
end

function StatusHuangjinDaodunDef:GetHurtMul(skillType)--tod0
    if not skillType == SKILL_TYPE.PHY_ATK then
        return self.m_atkHurMul
    end

    if self.m_atkHurMul == 0 then
        return self.m_atkHurMul
    end

    if self.m_leftCount > 0 and not self.m_isDefensiveState then
        self.m_leftCount = FixSub(self.m_leftCount, 1)

        self.m_statusKeepTime = FixFloor(self.m_statusKeepTime) -- 时间向下取整
        if self.m_statusKeepTime > 0 then
            self.m_atkHurMul = FixMul(self.m_atkHurMul, self.m_statusKeepTime)
            if self.m_atkHurMul > self.m_maxAtkHurtMul then -- 不能超过最大
                self.m_atkHurMul = self.m_maxAtkHurtMul
            end
        end

        return FixAdd(self.m_atkHurMul, 1)
    end
 
    return self.m_atkHurMul
end

function StatusHuangjinDaodunDef:Effect(actor)
    if actor and actor:IsLive() then
        if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end
end

function StatusHuangjinDaodunDef:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

function StatusHuangjinDaodunDef:Update(deltaMS, actor)
    if not actor or not actor:IsLive() then
        self.m_isDefensiveState = false
        self.m_leftCount = 0
        self.m_atkHurMul = 0
        self.m_statusKeepTime = 0
        self.m_leftMS = 0
        return StatusEnum.STATUSCONDITION_END
    end

    -- 引导机制。防御姿态状态可以被控制、浮空、击飞打断
    if actor:GetStatusContainer():IsFrozen() or actor:GetStatusContainer():IsDingShen() or actor:GetStatusContainer():IsSleep() then
        self.m_isDefensiveState = false
        self.m_leftMS = 0
    else
        self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
        if self.m_leftMS <= 0 then
            self:ClearEffect(actor)
            self.m_isDefensiveState = false
        else
            self.m_statusKeepTime = FixAdd(self.m_statusKeepTime, deltaMS)
        end
    end

    if self.m_leftMS <= 0 and self.m_leftCount <= 0 then
        return StatusEnum.STATUSCONDITION_END
    else
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
end

return StatusHuangjinDaodunDef