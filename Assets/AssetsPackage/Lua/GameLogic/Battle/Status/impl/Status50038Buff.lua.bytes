

local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local StatusEnum = StatusEnum
local LogError = Logger.LogError
local Log = Logger.Log
local ACTOR_ATTR = ACTOR_ATTR
local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local Status50038Buff = BaseClass("Status50038Buff", StatusBuff)

function Status50038Buff:__init()
    self.m_count = 0 -- 叠加限制次数
end

function Status50038Buff:Init(giver, attrReason, leftMS, count, effect, maxCount, subStatusType)
    StatusBuff.Init(self, giver, attrReason, leftMS, effect, maxCount, subStatusType)

    self.m_count = count
end

function Status50038Buff:GetStatusType()
    return StatusEnum.STATUSTYPE_INSCRIPTIONBUFF
end

function Status50038Buff:GetCount()
    return self.m_count
end

-- return actor isDie
function Status50038Buff:Update(deltaMS, actor) 
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end
    self.m_count = 0
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function Status50038Buff:Merge(newStatus, actor)
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_count = FixSub(self.m_count, 1)
    if self.m_count > 0 then
        self.m_leftMS = self.m_totalMS
        self:Effect(actor)
    end
end


return Status50038Buff
