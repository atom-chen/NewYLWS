
local StatusAllShield = require("GameLogic.Battle.Status.impl.StatusAllShield")
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixAdd = FixMath.add
local FixSub = FixMath.sub

local StatusAllTimeShield = BaseClass("StatusAllTimeShield", StatusAllShield)
 
function StatusAllTimeShield:Init(giver, hpStore, leftMS, effect)
    StatusAllShield.Init(self, giver, hpStore, effect)
    self:SetLeftMS(leftMS)
end

function StatusAllTimeShield:GetStatusType()
    return StatusEnum.STATUSTYPE_ALLTIMESHIELD
end

function StatusAllTimeShield:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)

    if self.m_leftMS > 0 and self.m_hpStore > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

return StatusAllTimeShield