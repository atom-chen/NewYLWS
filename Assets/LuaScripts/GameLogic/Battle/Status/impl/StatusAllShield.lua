
local StatusShieldBase = require("GameLogic.Battle.Status.impl.StatusShieldBase")
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixAdd = FixMath.add

local StatusAllShield = BaseClass("StatusAllShield", StatusShieldBase)

function StatusAllShield:GetStatusType()
    return StatusEnum.STATUSTYPE_ALLSHIELD
end

function StatusAllShield:Merge(newStatus, actor)
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    if battleLogic then
        battleLogic:AddShield(actor)
    end

    self.m_hpStore = FixAdd(self.m_hpStore, newStatus:GetHPStore())
end

return StatusAllShield