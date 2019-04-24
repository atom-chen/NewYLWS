local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local StatusEnum = StatusEnum

local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local StatusDianweiBuff = BaseClass("StatusDianweiBuff", StatusBuff)

function StatusDianweiBuff:__init()
    self.m_addCount = 0
end

function StatusDianweiBuff:Init(giver, attrReason, leftMS, effect, maxCount, subStatusType)
    StatusBuff.Init(self, giver, attrReason, leftMS, effect, maxCount, subStatusType)
    self.m_addCount = 1
end

function StatusDianweiBuff:GetStatusType()
    return StatusEnum.STATUSTYPE_DIANWEITIELI
end

function StatusDianweiBuff:AddAttrCount(count, actor)
    local tmpCount = self.m_addCount
    local realAddCount = count
    self.m_addCount = FixAdd(self.m_addCount, count)
    if self.m_addCount > self.m_maxCount then
        self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT 
        self.m_addCount = self.m_maxCount
        realAddCount = FixSub(self.m_maxCount, tmpCount)
    end

    for i=1, realAddCount do
        self.m_isAttrDefAdd = false
        self.m_leftMS = self.m_totalMS
        self:Effect(actor)
    end
end

function StatusDianweiBuff:Update(deltaMS, actor) 
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        if self.m_addCount >= self.m_maxCount then
            self:ClearEffect(actor)
            if actor and actor:IsLive() then
                actor:ShouldPerformSkill10173()
            end

            return StatusEnum.STATUSCONDITION_END, false
        end

        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    if actor and actor:IsLive() then
        actor:ClearSkill10173Count()
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusDianweiBuff:Attach(actor, isAttach)
    local mul = 1
    if not isAttach then
        mul = self.m_addCount
    end

    for _, ap in pairs(self.m_attrList) do
        local attrValue = ap.attrValue
        attrValue = FixMul(attrValue, mul)

        if not isAttach then
            attrValue = FixMul(-1, attrValue)
            if self.m_effectKey > 0 then
                EffectMgr:RemoveByKey(self.m_effectKey)
                self.m_effectKey = -1
            end

            self.m_addCount = 0
        else

            if self.m_effectMask and #self.m_effectMask > 0 then
                self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
            end
        end

        local isShowedAttrText = true
        if isAttach then
            isShowedAttrText = self:IsShowedAttrText(actor, ap.attrType, attrValue)
        end

        actor:GetData():AddFightAttr(ap.attrType, attrValue, isShowedAttrText)
    end
end

function StatusDianweiBuff:Merge(newStatus, actor) -- 合并規則是 刷新时间 buff叠加,达到最大层数，层数清零，buff加成清除，并且触发爆炸伤害
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_addCount = FixAdd(self.m_addCount, 1)
    self.m_leftMS = self.m_totalMS

    if self.m_addCount <= self.m_maxCount then
        self.m_isAttrDefAdd = false
        self:Effect(actor)
        return 
    end
end

return StatusDianweiBuff
