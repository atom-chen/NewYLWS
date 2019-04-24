local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local ACTOR_ATTR = ACTOR_ATTR


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusXiliangWeak = BaseClass("StatusXiliangWeak", StatusBase)

function StatusXiliangWeak:__init()
    self.m_phyAtkAdd = 0
    self.m_magicAtkAdd = 0
    self.m_hurtMul = 0
    self.m_isControlSkill = false
    self.m_key = false
    self.m_effectMask = false
end

function StatusXiliangWeak:Init(giver, leftMS, phyAtkAdd, magicAtkAdd)
    self.m_phyAtkAdd = phyAtkAdd
    self.m_magicAtkAdd = magicAtkAdd
    self.m_hurtMul = 1
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT
    self.m_isControlSkill = false
    self.m_key = false
    self.m_effectMask = false
    self:SetLeftMS(leftMS)
end

function StatusXiliangWeak:GetStatusType()
    return StatusEnum.STATUSTYPE_XILIANGWEAK
end


function StatusXiliangWeak:LogicEqual(newOne)
    if self:GetStatusType() ~= newOne:GetStatusType() or
       self:GetMergeRule() ~= newOne:GetMergeRule() then
        return false
    end

    return self.m_giver.skillID == newOne:GetGiver().skillID and self.m_giver.actorID == newOne:GetGiver().actorID
end

function StatusXiliangWeak:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusXiliangWeak:Effect(actor)
    self:Attach(actor, true)
    return false
end

function StatusXiliangWeak:ClearEffect(actor)
    self:Attach(actor, false)
end

function StatusXiliangWeak:Attach(actor, isAttach) 
    if not isAttach then
        self.m_phyAtkAdd = FixMul(self.m_phyAtkAdd, -1)
        self.m_magicAtkAdd = FixMul(self.m_magicAtkAdd, -1)
    end

    actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, self.m_phyAtkAdd)
    actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, self.m_magicAtkAdd)
end

function StatusXiliangWeak:GetHurtMul()
    return self.m_hurtMul
end

function StatusXiliangWeak:SetHurtMul(mul)
    self.m_hurtMul = mul
end

function StatusXiliangWeak:IsPositive()
    return false
end
return StatusXiliangWeak