local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local StatusSunquanBuff = BaseClass("StatusSunquanBuff", StatusBase)

function StatusSunquanBuff:__init()
    self.m_effectKey = -1
    self.m_reducePercent = 0
end

function StatusSunquanBuff:Init(giver, leftMS, reducePercent, effect)
    self.m_giver = giver
    self.m_effectMask = effect
    self:SetLeftMS(leftMS)
    self.m_effectKey = -1
    self.m_reducePercent = reducePercent
end


function StatusSunquanBuff:GetStatusType()
    return StatusEnum.STATUSTYPE_SUNQUANBUFF
end

function StatusSunquanBuff:GetSkillReducePercent()
    return self.m_reducePercent
end

function StatusSunquanBuff:Effect(actor)
    if actor then 
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end

    return false
end

function StatusSunquanBuff:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    self.m_reducePercent = 0
end

function StatusSunquanBuff:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

function StatusSunquanBuff:Merge(newStatus, actor) 
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_leftMS = self.m_totalMS
end


return StatusSunquanBuff