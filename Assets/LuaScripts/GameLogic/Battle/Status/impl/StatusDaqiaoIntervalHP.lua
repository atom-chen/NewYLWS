local base = require("GameLogic.Battle.Status.impl.StatusIntervalHP")
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local StatusEnum = StatusEnum

local StatusDaqiaoIntervalHP = BaseClass("StatusDaqiaoIntervalHP", base)

function StatusDaqiaoIntervalHP:Update(deltaMS, actor) 
    if actor:IsLive() and actor:GetStatusContainer():GetTotalShieldValue() <= 0 then
        return StatusEnum.STATUSCONDITION_END
    end
    
    return base.Update(self, deltaMS, actor)
end

function StatusDaqiaoIntervalHP:GetStatusType()
    return StatusEnum.STAUTSTYPE_DAQIAO_INTERVAL_HP
end

return StatusDaqiaoIntervalHP