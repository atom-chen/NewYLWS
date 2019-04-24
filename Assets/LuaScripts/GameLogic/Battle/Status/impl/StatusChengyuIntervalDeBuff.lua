
local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local StatusEnum = StatusEnum
local ACTOR_ATTR = ACTOR_ATTR

local StatusChengyuIntervalDeBuff = BaseClass("StatusChengyuIntervalDeBuff", StatusBuff)

function StatusChengyuIntervalDeBuff:__init()
    self.m_chgPhyDef = 0
    self.m_chgMagicDef = 0
    self.m_interval = 0
    self.m_chgPercent = 0
    self.m_skillLevel = 0
    self.m_maxMul = 0
    self.m_curMul = 0
end

function StatusChengyuIntervalDeBuff:Init(giver, attrReason, leftMS, chgPercent, skillLevel, maxMul, effect, maxCount, subStatusType)
    StatusBuff.Init(self, giver, attrReason, leftMS, effect, maxCount, subStatusType)

    self.m_chgPhyDef = 0
    self.m_chgMagicDef = 0
    self.m_interval = 1000
    self.m_chgPercent = chgPercent
    self.m_skillLevel = skillLevel
    self.m_maxMul = maxMul
    self.m_curMul = 0
end

function StatusChengyuIntervalDeBuff:IsPositive()
    return false
end

function StatusChengyuIntervalDeBuff:Effect(actor)
    if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then
        self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
    end

    return false
end

function StatusChengyuIntervalDeBuff:ReduceTargetAttr(actor)
    if actor and actor:IsLive() and self.m_chgPercent > 0 then
        local chgPhyDef = actor:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_DEF, self.m_chgPercent)
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1), true)
        self.m_chgPhyDef = FixAdd(self.m_chgPhyDef, chgPhyDef)

        local chgMagicDef = actor:CalcAttrChgValue(ACTOR_ATTR.BASE_MAGIC_DEF, self.m_chgPercent)
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_DEF, FixMul(chgMagicDef, -1), false)
        self.m_chgMagicDef = FixAdd(self.m_chgMagicDef, chgMagicDef)
    end
end

function StatusChengyuIntervalDeBuff:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if actor and actor:IsLive() then
        if self.m_chgPhyDef > 0 then
            actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, self.m_chgPhyDef, true)
            self.m_chgPhyDef = 0
        end

        if self.m_chgMagicDef > 0 then
            actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_DEF, self.m_chgMagicDef, false)
            self.m_chgMagicDef = 0
        end

        actor:AddEffect(106410) -- 结束特效
    end

    self.m_interval = 0
    self.m_chgPercent = 0
    self.m_skillLevel = 0
    self.m_maxMul = 0
    self.m_curMul = 0

    return false
end


function StatusChengyuIntervalDeBuff:SyncLeftMS(time)
    if self.m_skillLevel >= 3 and self.m_curMul < self.m_maxMul then
        self.m_leftMS = FixMul(self.m_leftMS, 2)
        self.m_curMul = FixAdd(self.m_curMul, 1)
    end

    if self.m_skillLevel >= 6 and self.m_leftMS < time then
        self.m_leftMS = time
    end
end


function StatusChengyuIntervalDeBuff:Update(deltaMS, actor) 
    self.m_interval = FixSub(self.m_interval, deltaMS)
    if self.m_interval <= 0 then
        self.m_interval = FixAdd(self.m_interval, 1000)

        self:ReduceTargetAttr(actor)
    end

    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

return StatusChengyuIntervalDeBuff
