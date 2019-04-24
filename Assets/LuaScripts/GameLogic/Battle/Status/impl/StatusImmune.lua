local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixRound = FixMath.round
local StatusEnum = StatusEnum

local StatusImmune = BaseClass("StatusImmune", StatusBase)

function StatusImmune:__init()
    self.m_immuneFlag = false
    self.m_effectKey = -1
end

function StatusImmune:Init(giver, leftMS, effect)
    self.m_giver = giver
    self.m_leftMS= leftMS
    self.m_immuneFlag = {}
    self.m_effectMask = effect
    self.m_effectKey = -1
end

function StatusImmune:Release()
    StatusBase.Release(self)
    self.m_immuneFlag = false
end

function StatusImmune:GetStatusType()
    return StatusEnum.STATUSTYPE_IMMUNE 
end

-- return actor isDie
function StatusImmune:Update(deltaMS, actor) 
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

-- @flag : StatusEnum.IMMUNEFLAG_
function StatusImmune:AddImmune(flag)
    self.m_immuneFlag[flag] = true
end

-- @flag : StatusEnum.IMMUNEFLAG_
function StatusImmune:ImmuneIt(flag)
    return self.m_immuneFlag[flag] == true
end

function StatusImmune:GetImmuneFlag()
    return self.m_immuneFlag
end

-- @immuneFlag : table, {[flag] = true or nil}
-- @flag : StatusEnum.IMMUNEFLAG_
function StatusImmune.IsImmune(immuneFlag, flag)
    return immuneFlag[flag] == true
end

function StatusImmune:Effect(actor)
    if actor then 
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end

    return false
end

function StatusImmune:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

return StatusImmune 
