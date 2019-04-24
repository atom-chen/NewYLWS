local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum

local StatusReduceControlTimebuff = BaseClass("StatusReduceControlTimebuff", StatusBase)

function StatusReduceControlTimebuff:__init() -- 此buff只用于boss减控时间一半，对于次数的控制无效
    self.m_effectKey = -1
end

function StatusReduceControlTimebuff:Init(giver, effect)
    self.m_giver = giver
    self.m_effectKey = -1
    self.m_effectMask = effect
end

function StatusReduceControlTimebuff:GetStatusType()
    return StatusEnum.STATUSTYPE_REDUCECONTROLBUFF
end


function StatusReduceControlTimebuff:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

function StatusReduceControlTimebuff:Update(deltaMS, actor)
    return StatusEnum.STATUSCONDITION_CONTINUE
end


function StatusReduceControlTimebuff:Effect(actor)
    if not actor then
        return true
    end

    if self.m_effectMask and #self.m_effectMask > 0 then
        self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
    end

    return false
end

return StatusReduceControlTimebuff