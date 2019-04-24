
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusHuaxiongDebuff = BaseClass("StatusHuaxiongDebuff", StatusBase)

function StatusHuaxiongDebuff:__init()
    self.m_leftMS = 0
    self.m_reducePercent = 0
    self.m_effectKey = 0
    self.m_effectMask = {}
end

function StatusHuaxiongDebuff:Init(giver, leftMS, reducePercent, effect)
    self.m_giver = giver
    self.m_effectMask = {effect}
    self.m_leftMS = leftMS
    self.m_reducePercent = reducePercent
    self:SetLeftMS(leftMS)
    self.m_effectKey = 0
end

function StatusHuaxiongDebuff:GetReducePercent()
    return self.m_reducePercent
end

function StatusHuaxiongDebuff:AddReducePercent(percent)
    self.m_reducePercent = FixAdd(self.m_reducePercent, percent)
end

function StatusHuaxiongDebuff:GetStatusType()
    return StatusEnum.STATUSTYPE_HURXIONG_DEBUFF
end

function StatusHuaxiongDebuff:Effect(actor)
    if actor then
        actor:ShowSkillMaskMsg(0, BattleEnum.SKILL_MASK_HUANGXIONG, TheGameIds.BattleBuffMaskBlack)
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end
end

function StatusHuaxiongDebuff:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

function StatusHuaxiongDebuff:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)

    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self:ClearEffect(actor)

    return StatusEnum.STATUSCONDITION_END, false
end

function StatusHuaxiongDebuff:IsPositive()
    return false
end

return StatusHuaxiongDebuff 