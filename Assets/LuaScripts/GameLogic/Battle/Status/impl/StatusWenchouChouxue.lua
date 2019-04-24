local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local StatusFactoryInst = StatusFactoryInst
local EffectMgr = EffectMgr
local ActorManagerInst = ActorManagerInst
local ACTOR_ATTR = ACTOR_ATTR

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusWenchouChouxue = BaseClass("StatusWenchouChouxue", StatusBase)

function StatusWenchouChouxue:__init()
    self.m_hpChg = 0
    self.m_leftCount = 0
    self.m_phyDef = 0
    self.m_attrChgCount = 0
    self.m_targetID = 0
    self.m_intervalTime = 0
    self.m_radius = 0

    self.m_actorEffectKey = 0
    self.m_targetEffectKe = 0
end

function StatusWenchouChouxue:Init(giver, count, hp, phyDef, targetID, radius, effect)
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT

    self.m_giver = giver
    self.m_hpChg = hp
    self.m_leftCount = count
    self.m_phyDef = phyDef
    self.m_targetID = targetID
    self.m_attrChgCount = 0
    self.m_intervalTime = 1000
    self.m_radius = radius
    
    self.m_actorEffectKey = 0
    self.m_targetEffectKey = 0
end

function StatusWenchouChouxue:GetStatusType()
    return StatusEnum.STATUSTYPE_WENCHOUCHOUXUE
end

function StatusWenchouChouxue:Effect(actor)
    local target = ActorManagerInst:GetActor(self.m_targetID)
    if target and target:IsLive() then
        self.m_targetEffectKey = target:AddEffect(107609)
    end

    if actor and actor:IsLive() then
        self.m_actorEffectKey = actor:AddEffect(107609)
    end
end

function StatusWenchouChouxue:Update(deltaMS, actor)
    local target = ActorManagerInst:GetActor(self.m_targetID)
    if not target or not target:IsLive() or not actor or not actor:IsLive() then
        self:ClearEffectAttrValue(actor, target)
        return StatusEnum.STATUSCONDITION_END
    end

    if not self:CheckDistance(actor, target) then
        self:ClearEffectAttrValue(actor, target)
        return StatusEnum.STATUSCONDITION_END
    end

    self.m_intervalTime = FixSub(self.m_intervalTime, deltaMS)
    if self.m_intervalTime > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    if self.m_leftCount > 0 then
        self.m_leftCount = FixSub(self.m_leftCount, 1)

        self.m_intervalTime = 1000
        self:EffectAttrValue(actor, target)

        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end
    
    self:ClearEffectAttrValue(actor, target)
    return StatusEnum.STATUSCONDITION_END, false
end

function StatusWenchouChouxue:CheckDistance(actor, target)
    local distanceSqr = (actor:GetPosition() - target:GetPosition()):SqrMagnitude()
    return distanceSqr <= FixMul(self.m_radius, self.m_radius) 
end

function StatusWenchouChouxue:EffectAttrValue(actor, target)
    local targetStatus = StatusFactoryInst:NewStatusDelayHurt(self.m_giver, FixMul(-1, self.m_hpChg), BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
    target:GetStatusContainer():Add(targetStatus, actor)

    local actorStatus = StatusFactoryInst:NewStatusDelayHurt(self.m_giver, self.m_hpChg, BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
    actor:GetStatusContainer():Add(actorStatus, actor)

    if self.m_phyDef > 0 then
        self.m_attrChgCount = FixAdd(self.m_attrChgCount, 1)
        target:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, FixIntMul(self.m_phyDef, -1))
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, self.m_phyDef)
    end
end


function StatusWenchouChouxue:ClearEffectAttrValue(actor, target)
    if self.m_phyDef > 0 and self.m_attrChgCount > 0 then
        if target and target:IsLive() then
            target:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, FixIntMul(self.m_phyDef, self.m_attrChgCount))
        end

        if actor and actor:IsLive() then
            actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, FixIntMul(FixMul(self.m_phyDef, self.m_attrChgCount), -1))
        end
    end

    if self.m_targetEffectKey > 0 then
        EffectMgr:RemoveByKey(self.m_targetEffectKey)
        self.m_targetEffectKey = -1
    end

    if self.m_actorEffectKey > 0 then
        EffectMgr:RemoveByKey(self.m_actorEffectKey)
        self.m_actorEffectKey = -1
    end

    if actor and actor:IsLive() then
        local actorCom = actor:GetComponent()
        if actorCom then
            actorCom:EndChouXueEffect()
        end
    end
end


function StatusWenchouChouxue:IsPositive()
    return false
end

return StatusWenchouChouxue