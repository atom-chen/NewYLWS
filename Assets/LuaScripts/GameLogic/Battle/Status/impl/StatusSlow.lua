local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local ACTOR_ATTR = ACTOR_ATTR


local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusSlow = BaseClass("StatusSlow", StatusBase)

-- 降低移动与动作
function StatusSlow:__init()
    self.m_chgMoveSpeed = 0
    self.m_chgAtkSpeed = 0
    self.m_leftMS = 0
end

function StatusSlow:Init(giver, leftMS, chgMoveSpeed, chgAtkSpeed, effect)
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT

    self.m_giver = giver
    self.m_chgMoveSpeed = chgMoveSpeed
    self.m_chgAtkSpeed = chgAtkSpeed
    self.m_leftMS = leftMS
end

function StatusSlow:Effect(actor)
    if actor and actor:IsLive() then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MOVESPEED, self.m_chgMoveSpeed)
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, self.m_chgAtkSpeed)
    end
end

function StatusSlow:ClearEffect(actor)
    if actor and actor:IsLive() then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MOVESPEED, FixMul(self.m_chgMoveSpeed, -1))
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, FixMul(self.m_chgAtkSpeed, -1))
    end
end

function StatusSlow:GetStatusType()
    return StatusEnum.STATUSTYPE_SLOW
end

function StatusSlow:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusSlow:IsPositive()
    return false
end
return StatusSlow