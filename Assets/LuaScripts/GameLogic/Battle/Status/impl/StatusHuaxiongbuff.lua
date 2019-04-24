local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local FixSub = FixMath.sub
local FixMod = FixMath.mod
local FixRand = BattleRander.Rand

local StatusHuaxiongbuff = BaseClass("StatusHuaxiongbuff", StatusBase)

function StatusHuaxiongbuff:__init()
    self.m_immuneMinHP = 0
    self.m_immuneRandValue = 0
end


function StatusHuaxiongbuff:Init(giver, immuneMinHP, immuneRandValue, effect)
    self.m_giver = giver
    self.m_effectKey = -1
    self.m_immuneMinHP = immuneMinHP
    self.m_immuneRandValue = immuneRandValue
end


function StatusHuaxiongbuff:GetStatusType()
    return StatusEnum.STATUSTYPE_HUAXIONGBUFF
end


function StatusHuaxiongbuff:IsImmune(actor)
    if not actor or not actor:IsLive() then
        return false
    end
    
    local curHP = actor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    if curHP > self.m_immuneMinHP then
        return false
    end

    local randVal = FixMod(FixRand(), 100)
    if randVal <= self.m_immuneRandValue then
        return true
    end

    return false
end


function StatusHuaxiongbuff:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end


function StatusHuaxiongbuff:Update(deltaMS, actor)
    return StatusEnum.STATUSCONDITION_CONTINUE
end


function StatusHuaxiongbuff:Effect(actor)
    if not actor then
        return true
    end

    if self.m_effectMask and #self.m_effectMask > 0 then
        self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
    end

    return false
end


function StatusHuaxiongbuff:IsClearByOther()
    return false
end

return StatusHuaxiongbuff