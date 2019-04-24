local FixDiv = FixMath.div
local FixNormalize = FixMath.Vector3Normalize
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixAngle = FixMath.Vector3Angle  --角度
local FixNewVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum

local StatusBase = BaseClass("StatusBase")

function StatusBase:__init()
    self.m_giver = StatusGiver.New()
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT 
    self.m_key = 0
    self.m_effectMask = {}  -- StatusEnum.STATUSEFFECT_
    self.m_clearable = true
    self.m_isClearOnDie = true
    self.m_canClearByOther = true -- 是否能被驱散
    self.m_leftMS = 0
    self.m_totalMS = 0
    self.m_isControlSkill = false
end

function StatusBase:__delete()
    self.m_giver = nil
end
function StatusBase:OnRelease()
    self.m_effectMask = {}
end

function StatusBase:Init()
    self.m_giver = StatusGiver.New()
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT 
    self.m_key = 0
    self.m_effectMask = {}  -- StatusEnum.STATUSEFFECT_
    self.m_clearable = true
    self.m_isClearOnDie = true
    self.m_canClearByOther = true -- 是否能被驱散
    self.m_leftMS = 0
    self.m_totalMS = 0
end
function StatusBase:Release()
    self:OnRelease()
end

function StatusBase:OnOwnerDie(actor)
end

function StatusBase:GetLeftMS()
    return self.m_leftMS
end

function StatusBase:GetTotalMS()
    return self.m_totalMS
end

function StatusBase:SetLeftMS(leftMS)
    self.m_leftMS = leftMS
    self.m_totalMS = leftMS
end

function StatusBase:SetEffectMask(effect)
    if not effect then
        return
    end
    if type(effect) == "table" then
        for _, e in pairs(effect) do
            table_insert(self.m_effectMask, e)
        end
    else
        table_insert(self.m_effectMask, effect)
    end
end

function StatusBase:GetStatusType()
    return 0
end

function StatusBase:GetMergeRule()
    return self.m_mergeRule
end

function StatusBase:LogicEqual(newOne)
    return self:GetStatusType() == newOne:GetStatusType() and
           self:GetMergeRule() == newOne:GetMergeRule()
end

function StatusBase:Mergeable(newOne)
    return true
end

function StatusBase:Clearable()
    return self.m_clearable
end

function StatusBase:SetClearable(b)
    self.m_clearable = b
end

function StatusBase:CanClearByOther()
    return self.m_canClearByOther
end

function StatusBase:SetKey(k)
    self.m_key = k
end

function StatusBase:GetKey()
    return self.m_key
end

function StatusBase:SetMergeRule(r)
    self.m_mergeRule = r
end

function StatusBase:GetMaxCount()
    return 0
end

-- return actor是否死亡
function StatusBase:Effect(actor)  
    return false
end

-- @hurtType : HURTTYPE 
-- @chgHP : int
-- @actor : actor 
-- @reason : HPCHGREASON
-- @keyFrame : int 
function StatusBase:EffectHP(hurtType, chgHP, actor, reason, judge, keyFrame)
    local showHit = false
    if chgHP < 0 then
        showHit = true
    end

    chgHP = actor:PreChgHP(self.m_giver, chgHP, hurtType, reason)
    actor:ChangeHP(self.m_giver, hurtType, chgHP, reason, judge, keyFrame, showHit)
end


function StatusBase:ClearEffect(actor)
end

function StatusBase:Merge(newStatus, actor)
end

-- return :1 STATUSCONDITION该状态是否结束
--         2 owner 是否 死亡
function StatusBase:Update(deltaMS, actor)
    return StatusEnum.STATUSCONDITION_CONTINUE, false
end

function StatusBase:GetGiver()
    return self.m_giver
end

function StatusBase:SetClearOnDie(b)
    self.m_isClearOnDie = b
end

function StatusBase:IsClearOnDie()
    return self.m_isClearOnDie
end

function StatusBase:IsClearByOther()
    return self.m_canClearByOther
end

function StatusBase:SetCanClearByOther(b)
    self.m_canClearByOther = b
end

function StatusBase:IsPositive()
    return true
end

-- @other : actor
-- @chgVal : int HP chgVal
-- @hpChgreason : HPCHGREASON
-- @hurtType : HURTTYPE
function StatusBase:OnHurtOther(other, chgVal, hpChgreason, hurtType)

end

-- @attacker : StatusGiver 
-- @chgVal : int   HP chgVal
-- @hpChgreason : HPCHGREASON
-- @hurtType : HURTTYPE
function StatusBase:OnHurt(attacker, chgVal, hpChgreason, hurtType)
end

function StatusBase:ExtendEffect(value)
end

-- @char : actor
-- @effect : StatusEnum.STATUSEFFECT_ 
function StatusBase:ShowEffect(actor, effectID)
    
    return EffectMgr:AddEffect(actor:GetActorID(), effectID, 1)
end

function StatusBase:SetControlSkill(isControlSkill)
    self.m_isControlSkill = isControlSkill
end

function StatusBase:IsControlSkill()
    return self.m_isControlSkill
end

return StatusBase