local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixRound = FixMath.round
local FixSub = FixMath.sub
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum

local StatusIntervalHP = BaseClass("StatusIntervalHP", StatusBase)

function StatusIntervalHP:__init()
    self.m_deltaHP = 0
    self.m_interval = 0
    self.m_chgCount = 0
    self.m_maxOverlayCount = 0
    self.m_intervalTime = 0
    self.m_effectKey = 0
    self.m_hurtType = BattleEnum.HURTTYPE_REAL_HURT
end

function StatusIntervalHP:Init(giver, deltaHP, interval, chgCount, effect, maxOverlayCount, hurtType)
    self.m_giver = giver
    self.m_deltaHP = deltaHP
    self.m_interval = interval
    self.m_chgCount = chgCount
    self.m_maxOverlayCount = maxOverlayCount or 0
    self.m_intervalTime = 0
    self.m_effectMask = {}
    self:SetEffectMask(effect)

    self.m_effectKey = 0
    self.m_hurtType = hurtType or BattleEnum.HURTTYPE_REAL_HURT
end

function StatusIntervalHP:GetStatusType()
    return StatusEnum.STAUTSTYPE_INTERVAL_HP 
end

function StatusIntervalHP:LogicEqual(newOne)
    if not StatusBase.LogicEqual(self, newOne) then
        return false
    end
    return self:GetMaxCount() == newOne:GetMaxCount()
end

function StatusIntervalHP:GetMaxCount()
    return self.m_maxOverlayCount
end

function StatusIntervalHP:ExtendEffect(value)
    self.m_chgCount = FixRound(FixMul(self.m_chgCount, value))
end

-- return actor isDie
function StatusIntervalHP:Effect(actor)
    if actor then
        local _, e = next(self.m_effectMask)
        if e then
            self.m_effectKey = self:ShowEffect(actor, e)
        end
    end
    return false
end

function StatusIntervalHP:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1   
    end
    
    return false
end

-- return actor isDie
function StatusIntervalHP:Update(deltaMS, actor) 
    self.m_intervalTime = FixAdd(self.m_intervalTime, deltaMS)
    if self.m_intervalTime < self.m_interval then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self.m_intervalTime = FixSub(self.m_intervalTime, self.m_interval)
    self.m_chgCount = FixSub(self.m_chgCount, 1)
    self:EffectHP(self.m_hurtType, self.m_deltaHP, actor, BattleEnum.HPCHGREASON_INTERVAL_BUFF, BattleEnum.ROUNDJUDGE_NORMAL, 0)
    local isDie = false
    if not actor:IsLive() then
        isDie = true
    end

    if self.m_chgCount > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, isDie
    end
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, isDie
end

function StatusIntervalHP:IsPositive()
    return self.m_deltaHP > 0 
end

return StatusIntervalHP