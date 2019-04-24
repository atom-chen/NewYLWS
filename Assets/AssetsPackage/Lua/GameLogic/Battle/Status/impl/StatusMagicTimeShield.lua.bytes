
local StatusMagicShield = require("GameLogic.Battle.Status.impl.StatusMagicShield")
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixAdd = FixMath.add
local FixSub = FixMath.sub

local StatusMagicTimeShield = BaseClass("StatusMagicTimeShield", StatusMagicShield)
 
function StatusMagicTimeShield:Init(giver, hpStore, leftMS, effect)
    StatusMagicShield.Init(self, giver, hpStore, effect)
    self:SetLeftMS(leftMS)
end

function StatusMagicTimeShield:GetStatusType()
    return StatusEnum.STATUSTYPE_MAGICTIMESHIELD
end

function StatusMagicTimeShield:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)

    if self.m_leftMS > 0 and self.m_hpStore > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

return StatusMagicTimeShield