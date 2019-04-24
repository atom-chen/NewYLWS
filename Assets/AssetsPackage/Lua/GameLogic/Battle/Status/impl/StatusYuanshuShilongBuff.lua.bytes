
local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")

local StatusYuanshuShilongBuff = BaseClass("StatusYuanshuShilongBuff", StatusBuff)

function StatusYuanshuShilongBuff:ClearEffect(actor)
    if actor and actor:IsLive() then
        actor:AddEffect(104707)
    end

    StatusBuff.ClearEffect(self, actor)
end

return StatusYuanshuShilongBuff
