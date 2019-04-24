
local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local StatusSunshangxiangDeBuff = BaseClass("StatusSunshangxiangDeBuff", StatusBuff)
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local StatusEnum = StatusEnum

function StatusSunshangxiangDeBuff:__init()
    self.m_curCount = 0
end


function StatusSunshangxiangDeBuff:Init(giver, attrReason, leftMS, effect, maxCount, subStatusType)
    StatusBuff.Init(self, giver, attrReason, leftMS, effect, maxCount, subStatusType)

    self.m_curCount = 1
end

function StatusSunshangxiangDeBuff:GetStatusType()
    return StatusEnum.STATUSTYPE_SUNSHANGXIANGDEBUFF
end

function StatusSunshangxiangDeBuff:Update(deltaMS, actor) 
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end


function StatusSunshangxiangDeBuff:Attach(actor, isAttach)
    for _, ap in pairs(self.m_attrList) do
        local attrValue = ap.attrValue
        if not isAttach then
            attrValue = FixMul(-1, FixMul(attrValue, self.m_curCount))
            if self.m_effectKey > 0 then
                EffectMgr:RemoveByKey(self.m_effectKey)
                self.m_effectKey = -1
            end
        else
            if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then
                self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
            end
        end

        local isShowedAttrText = self:IsShowedAttrText(actor, ap.attrType, attrValue)
        actor:GetData():AddFightAttr(ap.attrType, attrValue, isShowedAttrText)
    end
end

function StatusSunshangxiangDeBuff:Merge(newStatus, actor) 
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_isAttrDefReduce = false
    self:Effect(actor)
    self.m_leftMS = self.m_totalMS
    self.m_curCount = FixAdd(self.m_curCount, 1)
end

return StatusSunshangxiangDeBuff
