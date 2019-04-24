local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add 
local FixMul = FixMath.mul
local FixDiv = FixMath.div 
local FixFloor = FixMath.floor
local table_insert = table.insert

local StatusBindTargets = BaseClass("StatusBindTargets", StatusBase)

function StatusBindTargets:__init()
    self.m_effectKey = -1

    self.m_actorIDList = {}
    self.m_hurtPercenet = 0
    self.m_reducePercent = 0
    self.m_recoverHPPercent = 0

    self.m_recoverInterval = 0
    self.m_effectRecover = false
    self.m_effectCount = 0
    self.m_maxIntervalCount = 0
    self.m_recoverSkillCfg = nil

    self.m_otherHurt = 0
end

function StatusBindTargets:Init(giver, leftMS, reducePercent, hurtPercent, recoverHPPercent, recoverSkillCfg, maxIntervalCount, effect)
    self.m_giver = giver
    self.m_effectMask = effect
    self:SetLeftMS(leftMS)
    self.m_effectKey = -1

    self.m_actorIDList = {}
    self.m_hurtPercenet = hurtPercent
    self.m_reducePercent = reducePercent

    self.m_recoverHPPercent = recoverHPPercent
    self.m_recoverInterval = 1000
    self.m_effectRecover = false
    self.m_effectCount = 0
    self.m_maxIntervalCount = maxIntervalCount
    self.m_recoverSkillCfg = recoverSkillCfg
    self.m_otherHurt = 0
end

function StatusBindTargets:AddTargetID(targetID)
    table_insert(self.m_actorIDList, targetID)
end

function StatusBindTargets:GetStatusType()
    return StatusEnum.STATUSTYPE_BINDTARGETS
end

function StatusBindTargets:ReplayceHurt(hurt, reason)
    if hurt >= 0 then
        return hurt
    end

    if reason == BattleEnum.HPCHGREASON_BIND then
        return hurt
    end

    local count = 0
    for _, targetID in pairs(self.m_actorIDList) do
        if targetID and targetID > 0 then
            local target = ActorManagerInst:GetActor(targetID)
            if target and target:IsLive() then
                count = FixAdd(count, 1)
            end
        end
    end

    if count > 1 then
        hurt = FixMul(FixSub(1, self.m_reducePercent), hurt) -- 先降低x%，在承受 60%，其他40% 给队友  
        self.m_otherHurt = FixMul(self.m_hurtPercenet, hurt)
        hurt = FixSub(hurt, self.m_otherHurt)

        self.m_otherHurt = FixDiv(self.m_otherHurt, FixSub(count, 1))
    elseif count == 1 then
        hurt = FixMul(FixSub(1, self.m_reducePercent), hurt)
        self.m_otherHurt = 0
    end

    return FixFloor(hurt)
end


function StatusBindTargets:OnHurt(actor, chgVal, hpChgreason, giver, hurtType)
    if chgVal >= 0 or not actor or not actor:IsLive() then
        return
    end

    if hpChgreason == BattleEnum.HPCHGREASON_BIND then
        return
    end

    local actorID = actor:GetActorID()
    for _, targetID in pairs(self.m_actorIDList) do
        if targetID and targetID > 0 and actorID ~= targetID then
            local target = ActorManagerInst:GetActor(targetID)
            if target and target:IsLive() then
                local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, self.m_otherHurt, hurtType, 10, BattleEnum.HPCHGREASON_BIND, 1)
                target:GetStatusContainer():DelayAdd(statusHP)
            end
        end
    end

    if self.m_recoverHPPercent > 0 and self.m_recoverSkillCfg then
        if self.m_effectCount < self.m_maxIntervalCount then
            local giverActor = ActorManagerInst:GetActor(self.m_giver.actorID)
            if giverActor and giverActor:IsLive() then
                local recoverHP, isBaoji = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, giverActor, actor, self.m_recoverSkillCfg, self.m_recoverHPPercent) 
                local judge = BattleEnum.ROUNDJUDGE_NORMAL
                if isBaoji then
                    judge = BattleEnum.ROUNDJUDGE_BAOJI
                end

                local statusHP = StatusFactoryInst:NewStatusDelayHurt(self.m_giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 1, judge)
                actor:GetStatusContainer():DelayAdd(statusHP)

                self.m_effectCount = FixAdd(self.m_effectCount, 1)
                
                if not self.m_effectRecover then
                    self.m_effectRecover = true
                end
            end
        end
    end
end

function StatusBindTargets:Effect(actor)
    if actor then 
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end

    return false
end

function StatusBindTargets:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
    actor:ShowFloatHurt(ACTOR_ATTR.BE_HURT_END_DOWN)
    self.m_actorIDList = {}
end

function StatusBindTargets:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        if self.m_effectRecover then
            self.m_recoverInterval = FixSub(self.m_recoverInterval, deltaMS)
            if self.m_recoverInterval <= 0 then
                self.m_effectRecover = false
                self.m_effectCount = 0
                self.m_recoverInterval = FixAdd(self.m_recoverInterval, 1000)
            end
        end

        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

function StatusBindTargets:Merge(newStatus, actor) 
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    if not self:LogicEqual(newStatus) then
        return
    end

    self.m_leftMS = self.m_totalMS
end

function StatusBindTargets:IsPositive()
    return true
end

return StatusBindTargets