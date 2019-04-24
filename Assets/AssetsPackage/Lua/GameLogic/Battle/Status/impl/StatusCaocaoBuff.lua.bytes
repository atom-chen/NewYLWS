
local StatusShieldBase = require("GameLogic.Battle.Status.impl.StatusImmune")
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixAdd = FixMath.add

local StatusCaocaoBuff = BaseClass("StatusCaocaoBuff", StatusShieldBase)
 
function StatusCaocaoBuff:GetStatusType()
    return StatusEnum.STATUSTYPE_CAOCAOBUFF
end

function StatusCaocaoBuff:Update(deltaMS, actor) 
    if actor and actor:IsLive()  then
        local shieldBuff = actor:GetStatusContainer():GetAllShield()
        if shieldBuff then
            if shieldBuff:GetGiver().actorID == self.m_giver.actorID then
                return StatusEnum.STATUSCONDITION_CONTINUE
            end
        end
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

return StatusCaocaoBuff