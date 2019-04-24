
local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local StatusEnum = StatusEnum

local StatusYuanshuShijiaCurse = BaseClass("StatusYuanshuShijiaCurse", StatusBuff)

function StatusYuanshuShijiaCurse:GetStatusType()
    return StatusEnum.STATUSTYPE_YUANSHUSHIJIACURSE
end

function StatusYuanshuShijiaCurse:IsPositive()
    return false
end
return StatusYuanshuShijiaCurse
