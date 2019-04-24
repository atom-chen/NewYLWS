local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local table_insert = table.insert
local table_remove = table.remove
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixRound = FixMath.round
local FixSub = FixMath.sub
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum

local StatusIntervalHP20111 = BaseClass("StatusIntervalHP20111", StatusBase)

function StatusIntervalHP20111:__init()
    self.m_deltaHP = 0
    self.m_interval = 0
    self.m_chgCount = 0
    self.m_maxOverlayCount = 0
    self.m_intervalTime = 0
    self.m_phyDef = 0 
    self.m_effectKey = 0 
end

function StatusIntervalHP20111:Init(giver, deltaHP, interval, chgCount, phyDef, effect, maxOverlayCount)
    StatusBase.Init(self, giver, deltaHP, interval, chgCount, effect, maxOverlayCount)
    self.m_giver = giver
    self.m_deltaHP = deltaHP
    self.m_interval = interval
    self.m_chgCount = chgCount
    self.m_intervalTime = 0
    self.m_effectMask = {}
    self:SetEffectMask(effect)

    self.m_phyDef = phyDef
    self.m_effectKey = 0 
end

function StatusIntervalHP20111:GetStatusType()
    return StatusEnum.STAUTSTYPE_INTERVAL_HP_20111 
end
 
function StatusIntervalHP20111:Effect(actor)
    if self.m_phyDef and self.m_phyDef > 0 then
        if actor and actor:IsLive() then
            actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(self.m_phyDef, -1))

            local _, e = next(self.m_effectMask)
            if e then
                self.m_effectKey = self:ShowEffect(actor, e)
            end
        end
    end 

    return StatusBase.Effect(self, actor)
end

function StatusIntervalHP20111:ClearEffect(actor)
    if self.m_phyDef > 0 then
        if actor and actor:IsLive() then
            actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, self.m_phyDef)

            if self.m_effectKey > 0 then
            EffectMgr:RemoveByKey(self.m_effectKey)
                self.m_effectKey = -1   
            end
        end 
    end

    return StatusBase.ClearEffect(self, actor)
end

function StatusIntervalHP20111:Update(deltaMS, actor) 
    self.m_intervalTime = FixAdd(self.m_intervalTime, deltaMS)
    if self.m_intervalTime < self.m_interval then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self.m_intervalTime = FixSub(self.m_intervalTime, self.m_interval)
    self.m_chgCount = FixSub(self.m_chgCount, 1)
    self:EffectHP(BattleEnum.HURTTYPE_REAL_HURT, self.m_deltaHP, actor, BattleEnum.HPCHGREASON_INTERVAL_BUFF, BattleEnum.ROUNDJUDGE_NORMAL, 0)
    local isDie = false
    if not actor:IsLive() then
        isDie = true
    end

    if self.m_chgCount > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, isDie
    end
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, isDie
end

function StatusIntervalHP20111:IsPositive()
    return self.m_deltaHP > 0 
end


return StatusIntervalHP20111