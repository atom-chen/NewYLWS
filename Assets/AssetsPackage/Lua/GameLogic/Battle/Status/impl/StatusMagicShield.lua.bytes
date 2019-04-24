
local StatusShieldBase = require("GameLogic.Battle.Status.impl.StatusShieldBase")
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixAdd = FixMath.add

local StatusMagicShield = BaseClass("StatusMagicShield", StatusShieldBase)
 
function StatusMagicShield:GetStatusType()
    return StatusEnum.STATUSTYPE_MAGICSHIELD
end

function StatusMagicShield:Merge(newStatus, actor)
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    self.m_hpStore = FixAdd(self.m_hpStore, newStatus:GetHPStore())
end

return StatusMagicShield