
local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR

local StatusGuanhaiBuff = BaseClass("StatusGuanhaiBuff", StatusBuff)


function StatusGuanhaiBuff:GetStatusType()
    return StatusEnum.STATUSTYPE_GUANHAIBUFF
end


function StatusGuanhaiBuff:Merge(newStatus, actor) 
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_leftMS = self.m_totalMS
    self:Effect(actor)
end

return StatusGuanhaiBuff
