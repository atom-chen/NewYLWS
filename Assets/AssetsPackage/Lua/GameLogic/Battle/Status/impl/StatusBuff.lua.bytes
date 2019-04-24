
local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR

local StatusBuff = BaseClass("StatusBuff", StatusBase)

function StatusBuff:__init()
    self.m_maxCount = 0
    self.m_attrList = false
    self.m_subStatusType = StatusEnum.STATUSTYPE_ATTRBUFF
    self.m_attrChgReason = BattleEnum.AttrReason_NONE 

    self.m_isAttrAttackAdd = false
    self.m_isAttrAttackReduce = false
    self.m_isAttrDefAdd = false
    self.m_isAttrDefReduce = false

    self.m_effectKey = 0
end

-- @giver : StatusGiver
-- @attrReason : BattleEnum.AttrReason_
function StatusBuff:Init(giver, attrReason, leftMS, effect, maxCount, subStatusType)
    self.m_giver = giver
    self.m_attrChgReason = attrReason 
    self.m_attrList = {}
    if effect then
        self:SetEffectMask(effect) 
    end
    self:SetLeftMS(leftMS)

    if not subStatusType then
        subStatusType = StatusEnum.STATUSTYPE_ATTRBUFF
    end
    self.m_subStatusType = subStatusType
    self.m_maxCount = maxCount or 0
    
    self.m_isAttrAttackAdd = false
    self.m_isAttrAttackReduce = false
    self.m_isAttrDefAdd = false
    self.m_isAttrDefReduce = false
    self.m_effectKey = 0
end

function StatusBuff:GetAttrChgReason()
    return self.m_attrChgReason
end

function StatusBuff:LogicEqual(newOne)

    if self:GetStatusType() ~= newOne:GetStatusType() or
       self:GetMergeRule() ~= newOne:GetMergeRule() then
        return false
    end
    return self.m_attrChgReason == newOne:GetAttrChgReason() and
           self.m_giver.skillID == newOne:GetGiver().skillID and
           self:GetMaxCount() == newOne:GetMaxCount()
end

function StatusBuff:GetMaxCount()
    return self.m_maxCount
end

function StatusBuff:GetStatusType()
    return self.m_subStatusType
end

-- return actor isDie
function StatusBuff:Effect(actor)
    self:Attach(actor, true)
    return false
end

function StatusBuff:ClearEffect(actor)
    self.m_isAttrAttackAdd = false
    self.m_isAttrAttackReduce = false
    self.m_isAttrDefAdd = false
    self.m_isAttrDefReduce = false
    self:Attach(actor, false)
end

-- return actor isDie
function StatusBuff:Update(deltaMS, actor) 
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusBuff._MakeAttrPair(type, value)
    local o = {
        attrType = type,
        attrValue = value,
    }
    return o
end
-- @attrType: ACTOR_ATTR
function StatusBuff:AddAttrPair(attrType, attrValue)
    table_insert(self.m_attrList, StatusBuff._MakeAttrPair(attrType, attrValue))
end

function StatusBuff:Attach(actor, isAttach)
    for _, ap in pairs(self.m_attrList) do
        local attrValue = ap.attrValue
        if not isAttach then
            attrValue = FixMul(-1, ap.attrValue)
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

function StatusBuff:IsShowedAttrText(actor, attrType, attrValue)
    local old = actor:GetData():GetAttrValue(attrType) or 0
    local new = FixAdd(old, attrValue)
    if attrType == ACTOR_ATTR.FIGHT_PHY_ATK or attrType == ACTOR_ATTR.FIGHT_MAGIC_ATK then
        if old < new then
            if self.m_isAttrAttackAdd then
                return false
            end

            self.m_isAttrAttackAdd = true
        else
            if self.m_isAttrAttackReduce then
                return false
            end

            self.m_isAttrAttackReduce = true
        end
    elseif attrType == ACTOR_ATTR.FIGHT_PHY_DEF or attrType == ACTOR_ATTR.FIGHT_MAGIC_DEF then
        if old < new then
            if self.m_isAttrDefAdd then
                return false
            end

            self.m_isAttrDefAdd = true
        else
            if self.m_isAttrDefReduce then
                return false
            end

            self.m_isAttrDefReduce = true
        end
    end

    return true
end

function StatusBuff:IsPositive()
    for _, ap in pairs(self.m_attrList) do
        if ap.attrValue > 0 then
            return true
        end
    end
    return false
end

-- @target : Actor
function StatusBuff:AppendAttrPair(attrType, attrValue, target)
    if target then
        self:AddAttrPair(attrType, attrValue)
        target:GetData():AddFightAttr(attrType, attrValue)
    end
end

function StatusBuff:GetAttrChgValueByType(attrType)
    local nChg = 0
    for _, ap in pairs(self.m_attrList) do
        if ap.attrType == attrType then 
            nChg = FixAdd(nChg, ap.attrValue)
        end
    end
    return nChg
end

function StatusBuff:Merge(newStatus, actor) -- 合并規則是 刷新时间 如果其他效果，需要继承重写
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_leftMS = self.m_totalMS
end

return StatusBuff
