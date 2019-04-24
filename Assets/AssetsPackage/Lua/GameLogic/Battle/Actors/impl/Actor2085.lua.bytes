local FixMul = FixMath.mul
local FixAdd = FixMath.add

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2085 = BaseClass("Actor2085", Actor)

function Actor2085:__init()
    self.m_recoverMul = 0
end

function Actor2085:SetRecoverMul(mul)
    self.m_recoverMul = mul
end

function Actor2085:PreChgHP(giver, chgHP, hurtType, reason)
    chgHP = Actor.PreChgHP(self, giver, chgHP, hurtType, reason)

    if chgHP > 0 and self.m_recoverMul > 0 then
        chgHP = FixAdd(chgHP, FixMul(self.m_recoverMul, chgHP))
    end

    return chgHP
end

return Actor2085