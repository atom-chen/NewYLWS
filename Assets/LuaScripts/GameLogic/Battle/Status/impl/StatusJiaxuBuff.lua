
local StatusBase = require("GameLogic.Battle.Status.impl.StatusBuff")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local StatusEnum = StatusEnum
local LogError = Logger.LogError
local ACTOR_ATTR = ACTOR_ATTR

local StatusJiaxuBuff = BaseClass("StatusJiaxuBuff", StatusBase)
function StatusJiaxuBuff:__init()
    self.m_chgPercent = 0
    self.m_curPercent = 0
    self.m_chgMagicAtk = 0
end

function StatusJiaxuBuff:Init(giver, chgPercent, effect)
    StatusBase.Init(self, giver, nil, 0, effect, maxCount, nil)
    self.m_giver = giver
    self.m_chgPercent = chgPercent
    self.m_curPercent = 0
    self.m_chgMagicAtk = 0
end

function StatusJiaxuBuff:GetStatusType()
    return StatusEnum.STATUSTYPE_JIAXU_BUFF
end

function StatusJiaxuBuff:Update(deltaMS, actor) 
    return StatusEnum.STATUSCONDITION_CONTINUE, false
end

function StatusJiaxuBuff:AddAttrPair(attrType, attrValue)
    self.m_attrType = attrType
end

function StatusJiaxuBuff:Effect(actor)  
    if actor and actor:IsLive() then
        local maxPercent = actor:Get10463A()
        if self.m_curPercent < maxPercent then
            local tmpChgPercent = self.m_chgPercent
            local last = self.m_curPercent
            self.m_curPercent = FixAdd(self.m_curPercent, self.m_chgPercent)
            if self.m_curPercent > maxPercent then
                tmpChgPercent = FixSub(maxPercent, last)
                self.m_curPercent = maxPercent
            end

            local actorMagic = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
            local chgMagicAtk = FixIntMul(actorMagic, tmpChgPercent)
            self.m_chgMagicAtk = FixAdd(self.m_chgMagicAtk, chgMagicAtk)
            -- local isShowedAttrText = self:IsShowedAttrText(actor, self.m_attrType, chgMagicAtk)
            actor:GetData():AddFightAttr(self.m_attrType, chgMagicAtk, true)
        end
    end

    return false
end

function StatusJiaxuBuff:ClearEffect(actor)
    actor:GetData():AddFightAttr(self.m_attrType, FixMul(self.m_chgMagicAtk, -1), true)
    self.m_chgPercent = 0
    self.m_curPercent = 0
    self.m_chgMagicAtk = 0
end

function StatusJiaxuBuff:Merge(newStatus, actor)
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self:Effect(actor)
end


return StatusJiaxuBuff
