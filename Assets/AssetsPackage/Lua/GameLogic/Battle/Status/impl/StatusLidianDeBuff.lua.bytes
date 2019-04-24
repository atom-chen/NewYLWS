local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")

local StatusLidianDeBuff = BaseClass("StatusLidianDeBuff", StatusBuff)

function StatusLidianDeBuff:__init()
    self.m_hurtMul = 1
end

function StatusLidianDeBuff:Init(giver, attrReason, leftMS, hurtMul, effect, maxCount, subStatusType)
    StatusBuff.Init(self, giver, attrReason, leftMS, effect, maxCount, subStatusType)

    self.m_hurtMul = hurtMul
end

function StatusLidianDeBuff:GetHurtMul()
    return self.m_hurtMul
end

return StatusLidianDeBuff
