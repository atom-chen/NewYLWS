
local StatusBase = require("GameLogic.Battle.Status.impl.StatusBuff")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local StatusEnum = StatusEnum
local ACTOR_ATTR = ACTOR_ATTR
local FixMod = FixMath.mod

local StatusZhouyuBuff = BaseClass("StatusZhouyuBuff", StatusBase)
-- 10293
function StatusZhouyuBuff:__init()
    self.m_count = 0
    self.m_effectKey = 0
    self.m_maxCount = 0
end

function StatusZhouyuBuff:Init(giver, attrReason, leftMS, effect, maxCount)
    StatusBase.Init(self, giver, attrReason, leftMS, effect, nil, nil)
    
    self.m_count = 1
    self.m_maxCount = maxCount
    self.m_effectKey = 0
    self:SetLeftMS(leftMS)
end

function StatusZhouyuBuff:GetStatusType()
    return StatusEnum.STAUTSTYPE_ZHOUYUBUFF
end

function StatusZhouyuBuff:Update(deltaMS, actor) 
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    if actor and actor:IsLive() then
        actor:ClearBuffMaskCount()
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusZhouyuBuff:Attach(actor, isAttach) 
    for _, ap in pairs(self.m_attrList) do
        local attrValue = ap.attrValue
        if not isAttach then
            local count = self.m_count
            if self.m_count > self.m_maxCount then
                count = self.m_maxCount
            end
            attrValue = FixMul(-1, FixMul(ap.attrValue, count))
            if self.m_effectKey > 0 then
                EffectMgr:RemoveByKey(self.m_effectKey)
                self.m_effectKey = -1
            end

            self.m_count = 0
            self.m_maxCount = 0
        else
            if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then
                self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
            end
        end
        
        local isShowedAttrText = self:IsShowedAttrText(actor, ap.attrType, attrValue)
        actor:GetData():AddFightAttr(ap.attrType, attrValue, true)
    end
end


function StatusZhouyuBuff:Merge(newStatus, actor)
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_count = FixAdd(self.m_count, 1)
    self.m_leftMS = self.m_totalMS
    if self.m_count <= self.m_maxCount then
        self:Effect(actor)
    end
    if FixMod(self.m_count, 6) == 0 then
        actor:Call()
    end
end


return StatusZhouyuBuff
