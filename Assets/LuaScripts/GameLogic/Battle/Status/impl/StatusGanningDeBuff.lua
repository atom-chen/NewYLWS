local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR

local StatusGanningDeBuff = BaseClass("StatusGanningDeBuff", StatusBuff)

function StatusGanningDeBuff:__init()
    self.m_mediaID = 0
    self.m_isStealAtk = false
    self.m_reduceCount = 0
end

function StatusGanningDeBuff:Init(giver, attrReason, leftMS, mediaID, isStealAtk, effect, maxCount, subStatusType)
    StatusBuff.Init(self, giver, attrReason, leftMS, effect, maxCount, subStatusType)

    self.m_mediaID = mediaID
    self.m_isStealAtk = isStealAtk
    self.m_reduceCount = 0
end

function StatusGanningDeBuff:GetFromMediaID()
    return self.m_mediaID
end

-- return actor isDie
function StatusGanningDeBuff:Effect(actor)
    self:Attach(actor, true)
    
    self.m_reduceCount = FixAdd(self.m_reduceCount, 1)
    return false
end

function StatusGanningDeBuff:ClearEffect(actor)
    self.m_isAttrAttackAdd = false
    self.m_isAttrAttackReduce = false
    self.m_isAttrDefAdd = false
    self.m_isAttrDefReduce = false
    self:Attach(actor, false)
end


function StatusGanningDeBuff:Attach(actor, isAttach)
    for _, ap in pairs(self.m_attrList) do
        local attrValue = ap.attrValue
        if not isAttach then
            attrValue = FixMul(-1, ap.attrValue)
            attrValue = FixMul(self.m_reduceCount, attrValue)
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
        
        if self.m_isStealAtk then
            local giverActor = ActorManagerInst:GetActor(self.m_giver.actorID)
            if giverActor and giverActor:IsLive() then
                giverActor:GetData():AddFightAttr(ap.attrType, FixMul(attrValue, -1), isShowedAttrText)
            end
        end
    end
end


function StatusGanningDeBuff:IsPositive()
    return false
end

function StatusGanningDeBuff:Merge(newStatus, actor) -- 合并規則是 刷新时间 两个涡旋重合时，重合区域的目标会下降两次双攻
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_isAttrAttackReduce = false
    self.m_isAttrAttackAdd = false
    self:Effect(actor)
    self.m_leftMS = self.m_totalMS
end

function StatusGanningDeBuff:Mergeable(newOne)
    return self.m_mediaID == newOne:GetFromMediaID()
end

return StatusGanningDeBuff
