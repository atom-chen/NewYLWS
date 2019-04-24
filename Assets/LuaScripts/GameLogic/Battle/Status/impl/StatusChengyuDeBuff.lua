
local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local FixAdd = FixMath.add
local FixMul = FixMath.mul

-- 仅用于程昱失明状态，只对命中做处理
local StatusChengyuDeBuff = BaseClass("StatusChengyuDeBuff", StatusBuff)

function StatusChengyuDeBuff:__init()
    self.m_chgValue = 0
end

function StatusChengyuDeBuff:Init(giver, attrReason, leftMS, effect, maxCount, subStatusType)
    StatusBuff.Init(self, giver, attrReason, leftMS, effect, maxCount, subStatusType)

    self.m_chgValue = 0
    self.m_effectMask = {106411}
end

function StatusChengyuDeBuff:IsPositive()
    return false
end

function StatusChengyuDeBuff:Effect(actor)
    if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then
        self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
    end

    local attrInfo = self.m_attrList[1]
    if attrInfo then
        local attrValue = attrInfo.attrValue
        actor:GetData():AddFightAttr(attrInfo.attrType, attrValue, true)
        self.m_chgValue = FixAdd(self.m_chgValue, attrValue)
    end

    return false
end

function StatusChengyuDeBuff:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if actor and actor:IsLive() then
        local attrInfo = self.m_attrList[1]
        if attrInfo then
            actor:GetData():AddFightAttr(attrInfo.attrType, FixMul(self.m_chgValue, -1), true)
            self.m_chgValue = 0
        end
    end

    return false
end

function StatusChengyuDeBuff:Merge(newStatus, actor) 
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self:Effect(actor)
    self.m_leftMS = self.m_totalMS
end

return StatusChengyuDeBuff
