local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2056 = BaseClass("Actor2056", Actor)
 
function Actor2056:__init()
    self.m_chgMagicAtk = 0
    self.m_chgPercent = 0
end


function Actor2056:LogicOnFightEnd()
    if self.m_chgMagicAtk > 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, FixIntMul(-1, self.m_chgMagicAtk))
    end

    self.m_chgMagicAtk = 0
    self.m_chgPercent = 0
end

function Actor2056:AddMagicAtk(percent, maxPercent)
    if percent <= 0 then
        return
    end

    if self.m_chgPercent >= maxPercent then
        return
    end

    local lastPercent = self.m_chgPercent
    self.m_chgPercent = FixAdd(self.m_chgPercent, percent)
    if self.m_chgPercent > maxPercent then
        percent = FixSub(maxPercent, percent)
        self.m_chgPercent = maxPercent
    end

    local chgMagicAtk = self:CalcAttrChgValue(ACTOR_ATTR.BASE_MAGIC_ATK, percent)
    self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk)
    self.m_chgMagicAtk = FixAdd(self.m_chgMagicAtk, chgMagicAtk)
end

return Actor2056