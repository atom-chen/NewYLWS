local FixAdd = FixMath.add 

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2014 = BaseClass("Actor2014", Actor)

function Actor2014:__init()
   self.m_ChgedMagicAtkPercent = 0
end 

function Actor2014:SetChgedMagicAtkPercent(value)
    self.m_ChgedMagicAtkPercent = FixAdd(self.m_ChgedMagicAtkPercent, value)
end

function Actor2014:GetChgedMagicAtkPercent()
    return self.m_ChgedMagicAtkPercent
end

function Actor2014:ClearChgedMagicAtkPercent()
    self.m_ChgedMagicAtkPercent = 0
end

 
 

return Actor2014