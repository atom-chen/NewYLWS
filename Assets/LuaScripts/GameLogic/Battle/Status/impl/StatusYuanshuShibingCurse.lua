
local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local StatusEnum = StatusEnum

local StatusYuanshuShibingCurse = BaseClass("StatusYuanshuShibingCurse", StatusBuff)

function StatusYuanshuShibingCurse:GetStatusType()
    return StatusEnum.STATUSTYPE_YUANSHUSHIBINGCURSE
end

function StatusYuanshuShibingCurse:IsPositive()
    return false
end
return StatusYuanshuShibingCurse
