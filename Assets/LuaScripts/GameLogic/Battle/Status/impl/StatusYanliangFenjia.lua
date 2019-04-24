
local StatusBuff = require("GameLogic.Battle.Status.impl.StatusBuff")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixMod = FixMath.mod
local StatusEnum = StatusEnum
local ACTOR_ATTR = ACTOR_ATTR
local FixRand = BattleRander.Rand
local IsInCircle = SkillRangeHelper.IsInCircle
local FixIntMul = FixMath.muli

local StatusYanliangFenjia = BaseClass("StatusYanliangFenjia", StatusBuff)

function StatusYanliangFenjia:__init()
    self.m_intervalTime = 0
    self.m_reduceAttrCount = 0
    self.m_maxCount = 0
    self.m_effectKey = -1
    self.m_chgPercent = 0
    self.m_chgValue = 0
    self.m_chgMagicPercent = 0
    self.m_magicChg = 0
end

function StatusYanliangFenjia:Init(giver, attrReason, intervalTime, chgPercent, magicPercent, effect, maxCount, subStatusType)
    StatusBuff.Init(self, giver, attrReason, leftMS, effect, maxCount, subStatusType)
    self.m_effectMask = effect

    self.m_intervalTime = intervalTime
    self.m_reduceAttrCount = 0
    self.m_maxCount = maxCount
    self.m_effectKey = -1
    self.m_chgPercent = chgPercent -- 增加为正数，减少为负数
    self.m_chgValue = 0
    self.m_chgMagicPercent = magicPercent
    self.m_magicChg = 0
end

function StatusYanliangFenjia:GetStatusType()
    return StatusEnum.STATUSTYPE_YANGLIANG_FENJIA
end
--每秒降低{y2}%的物防，并同步降低物防下降值{z2}%的法防。
function StatusYanliangFenjia:Attach(actor, isAttach) 
    if not actor then
        return
    end

    for _, ap in pairs(self.m_attrList) do
        local attrValue = 0
        if not isAttach then
            attrValue = self.m_chgValue
            if self.m_effectKey > 0 then
                EffectMgr:RemoveByKey(self.m_effectKey)
                self.m_effectKey = -1
            end
        else
            --self.m_reduceAttrCount = FixAdd(self.m_reduceAttrCount, 1)

            if self.m_effectMask and #self.m_effectMask > 0 and self.m_effectKey <= 0 then
                self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
            end
    
            attrValue = actor:CalcAttrChgValue(ap.attrType, self.m_chgPercent)
            self.m_chgValue = FixAdd(self.m_chgValue, FixMul(attrValue, -1))
        end

        actor:GetData():AddFightAttr(ap.attrType, attrValue, true)
        if attrValue < 0 then
            if self.m_chgMagicPercent > 0 then
                local chgValue = FixIntMul(FixMul(attrValue, -1), self.m_chgMagicPercent)
                if chgValue > 0 then
                    actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_DEF, FixMul(chgValue, -1), false)
                    self.m_magicChg = FixAdd(self.m_magicChg, chgValue)
                end
            end
        else
            if self.m_magicChg > 0 then
                actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_DEF, self.m_magicChg, false)
                self.m_magicChg = 0
            end
        end
    end
end


function StatusYanliangFenjia:Update(deltaMS, actor) 
    self.m_intervalTime = FixSub(self.m_intervalTime, deltaMS)
    if self.m_intervalTime > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self.m_maxCount = FixSub(self.m_maxCount, 1)
    self:Effect(actor)

    if self.m_maxCount > 0 then
        self.m_intervalTime = FixAdd(self.m_intervalTime, 1000)
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end


return StatusYanliangFenjia
