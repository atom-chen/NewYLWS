
local StatusAllShield = require("GameLogic.Battle.Status.impl.StatusAllShield")
local StatusEnum = StatusEnum

local StatusTaishiciShield = BaseClass("StatusTaishiciShield", StatusAllShield)

function StatusTaishiciShield:GetStatusType()
    return StatusEnum.STATUSTYPE_TAISHICISHIELD
end


function StatusTaishiciShield:ClearEffect(actor)
    StatusAllShield.ClearEffect(self, actor)
    
    local taishiciImmune = actor:GetStatusContainer():GetTaishiciImmune()
    if taishiciImmune then
        taishiciImmune:SetLeftMS(0)
    end
end


function StatusTaishiciShield:Effect(actor)
    StatusAllShield.Effect(self, actor)

    if actor and actor:IsLive() then
        local level = actor:Get10403Level()
        if level >= 4 then
            local immuneBuff = StatusFactoryInst:NewStatusTaishiciImmune(self.m_giver, 99999999999)
            immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
            actor:GetStatusContainer():DelayAdd(immuneBuff)
        end
    end
end

return StatusTaishiciShield