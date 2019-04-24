
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixSub = FixMath.sub

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusStun = BaseClass("StatusStun", StatusBase)


function StatusStun:__init()
    self.m_leftMS = 0
end

--@effect : STATUSEFFECT or ipairs {STATUSEFFECT, ...}
function StatusStun:Init(giver, leftMS, effect)
    self.m_giver = giver
    self.m_effectMask = {20013}
    self.m_leftMS = leftMS
    -- self:SetEffectMask(effect) 
    self:SetLeftMS(leftMS)
end

function StatusStun:OnRelease()
end

function StatusStun:GetStatusType()
    return StatusEnum.STATUSTYPE_STUN
end

function StatusStun:Effect(actor)
    if actor then
        actor:Stun()

        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end
end

function StatusStun:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if actor then
        actor:Idle()
    end
end

--
function StatusStun:Update(deltaMS, actor) 
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)

    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end
    self:ClearEffect(actor)

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusStun:IsPositive()
    return false
end

return StatusStun 