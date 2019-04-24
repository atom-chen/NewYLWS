local StatusEnum = StatusEnum
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local ACTOR_ATTR = ACTOR_ATTR

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusYanliangCanren = BaseClass("StatusYanliangCanren", StatusBase)
 
function StatusYanliangCanren:__init()
    self.m_effectKey = -1
end

function StatusYanliangCanren:Init(giver, leftMS, effect)
    StatusBase.Init(self, giver, leftMS, addBaojiPercent, phyDef, effect)
    self:SetLeftMS(leftMS)
    self.m_giver = giver
    self.m_effectMask = effect
    self.m_effectKey = -1
end

function StatusYanliangCanren:AddLeftMS(time)
    self.m_leftMS = FixAdd(self.m_leftMS, time)
end

function StatusYanliangCanren:GetStatusType()
    return StatusEnum.STATUSTYPE_YANGLIANG_CANREN
end

function StatusYanliangCanren:Effect(actor)
    if actor and actor:IsLive() then
        if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end
end

function StatusYanliangCanren:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

function StatusYanliangCanren:Merge(newStatus, actor)
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    self.m_leftMS = self.m_totalMS
end


function StatusYanliangCanren:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

return StatusYanliangCanren