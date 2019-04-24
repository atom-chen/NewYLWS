local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local table_insert = table.insert

local StatusFear = BaseClass("StatusFear", StatusBase)

function StatusFear:__init()
   self.m_attrList = false 
   self.m_effectKey = 0
end

function StatusFear:Init(giver, leftMS, effect)
    self.m_giver = giver
    if effect then
        self.m_effectMask = effect
    else
        
        self.m_effectMask = {20023}
    end
    self.m_attrList = {}
    self.m_effectKey = 0
    self:SetLeftMS(leftMS)
end

function StatusFear:GetStatusType()
    return StatusEnum.STATUSTYPE_FEAR
end

function StatusFear:Effect(actor)
    if not actor then
        return false
    end

    if self.m_effectMask then
        local _,e = next(self.m_effectMask)
        if e then
            self.m_effectKey = self:ShowEffect(actor, e)
        end
    end

    actor:GetAI():RandMove(self.m_leftMS, 500)
    self:Attach(actor, true)
    return false;
end

function StatusFear:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if not actor then
        return
    end
    
    actor:GetAI():SpecialStateEnd()
    self:Attach(actor, false)
end

function StatusFear:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusFear:IsPositive()
    return false
end

function StatusFear:MakeAttrPair(type, value)
    local o = {
        attrType = type,
        attrValue = value
    }
    return o
end

function StatusFear:AddAttrPair(attrType, attrValue)
    table_insert(self.m_attrList, self:MakeAttrPair(attrType, attrValue))
end

function StatusFear:Attach(actor, isAttach)
    for _,ap in pairs(self.m_attrList) do
        local attrValue = ap.attrValue
        if not isAttach then
            attrValue = FixMul(-1, attrValue)
        end
        actor:GetData():AddFightAttr(ap.attrType, attrValue)
        --TODO show effect
    end
end

return StatusFear