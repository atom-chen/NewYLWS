
local StatusBase = require("GameLogic.Battle.Status.impl.StatusBuff")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local StatusEnum = StatusEnum
local ACTOR_ATTR = ACTOR_ATTR

local StatusXiahouyuanDeBuff = BaseClass("StatusXiahouyuanDeBuff", StatusBase)

function StatusXiahouyuanDeBuff:__init()
    self.m_count = 0
    self.m_effectKey = 0
end

function StatusXiahouyuanDeBuff:Init(giver, attrReason, leftMS, effect, maxCount, subStatusType)
    StatusBase.Init(self, giver, attrReason, leftMS, effect, maxCount, subStatusType)
    
    self.m_count = 1
    self.m_effectKey = 0
    self:SetLeftMS(leftMS)
end

function StatusXiahouyuanDeBuff:GetStatusType()
    return StatusEnum.STATUSTYPE_XIAHOUYUANDEBUFF
end

function StatusXiahouyuanDeBuff:Update(deltaMS, actor) 
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end
    
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusXiahouyuanDeBuff:Attach(actor, isAttach) 
    for _, ap in pairs(self.m_attrList) do
        local attrValue = ap.attrValue
        if not isAttach then
            attrValue = FixMul(-1, FixMul(ap.attrValue, self.m_count))
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


function StatusXiahouyuanDeBuff:Merge(newStatus, actor) -- 防御叠加，时间重置
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_count = FixAdd(self.m_count, 1)
    self.m_leftMS = self.m_totalMS
    self:Effect(actor)
end


return StatusXiahouyuanDeBuff
