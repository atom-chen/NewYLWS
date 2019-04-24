local StatusImmune = require("GameLogic.Battle.Status.impl.StatusImmune")

local StatusXunyuImmune = BaseClass("StatusXunyuImmune", StatusImmune)

function StatusXunyuImmune:GetStatusType()
    return StatusEnum.STATUSTYPE_XUNYUIMMUNE 
end

return StatusXunyuImmune 
