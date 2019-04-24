local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2068 = BaseClass("Actor2068", Actor)

function Actor2068:__init()
    self.m_attrValue = 0
end


function Actor2068:AddAttr(percent)
    self.m_attrValue = percent
    self:GetData():AddFightAttr(ACTOR_ATTR.PHY_BAOJI_PROB_CHG, self.m_attrValue)
end

function Actor2068:ReduceAttr()
    self:GetData():AddFightAttr(ACTOR_ATTR.PHY_BAOJI_PROB_CHG, FixMul(self.m_attrValue, -1))
    self.m_attrValue = 0
end


function Actor2068:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)
    if skillCfg.id == 20681 and self.m_attrValue > 0 then
        self:ReduceAttr()
    end
end

return Actor2068