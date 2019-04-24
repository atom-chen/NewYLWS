local StatusImmune = require("GameLogic.Battle.Status.impl.StatusImmune")

local StatusTaishiciImmune = BaseClass("StatusTaishiciImmune", StatusImmune)

function StatusTaishiciImmune:GetStatusType()
    return StatusEnum.STATUSTYPE_TAISHICIIMMUNE 
end

-- -- return actor isDie
-- function StatusTaishiciImmune:Update(deltaMS, actor) 
--     if not actor or not actor:IsLive() then
--         self:ClearEffect(actor)
--         return StatusEnum.STATUSCONDITION_END, false
--     end

--     local actorShield = actor:GetStatusContainer():GetTaishiciShield()
--     if not actorShield or actorShield:GetHPStore() <= 0 then
--         self:ClearEffect(actor)
--         return StatusEnum.STATUSCONDITION_END, false
--     end

--     self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
--     if self.m_leftMS > 0 then
--         return StatusEnum.STATUSCONDITION_CONTINUE, false
--     end

--     self:ClearEffect(actor)
--     return StatusEnum.STATUSCONDITION_END, false
-- end


return StatusTaishiciImmune 
