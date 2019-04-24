
local table_insert = table.insert
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local IsInCircle = SkillRangeHelper.IsInCircle
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusJiaxuDebuff = BaseClass("StatusJiaxuDebuff", StatusBase)

function StatusJiaxuDebuff:__init()
    self.m_leftMS = 0
    self.m_effectKey = 0
    self.m_effectMask = {}
    self.m_maxHurt = 0
    self.m_hurtRadius = 0
    self.m_intervalHurt = 0
    self.m_skillLevel = 0
    self.m_targetRecoverHp = 0
    self.m_intervalTime = 1000
    self.m_skillTime = 0
    self.m_copyRadius = 0
    self.m_effect = nil
    self.m_hurtPercent = 0
end

function StatusJiaxuDebuff:Init(giver, leftMS, maxHurt, hurtRadius, intervalHurt, skillLevel, copyRadius, hurtPercent, effect)
    self.m_giver = giver
    self.m_effectMask = effect
    self.m_leftMS = leftMS
    self.m_skillTime = leftMS
    self.m_maxHurt = maxHurt
    self.m_hurtRadius = hurtRadius
    self.m_intervalHurt = intervalHurt
    self.m_skillLevel = skillLevel
    self.m_targetRecoverHp = 0
    self.m_intervalTime = 1000
    self.m_copyRadius = copyRadius
    self.m_effect = effect
    self.m_effectKey = 0
    self.m_hurtPercent = hurtPercent
    self:SetLeftMS(leftMS)

    local giverActor = ActorManagerInst:GetActor(self.m_giver.actorID)
    if giverActor and giverActor:IsLive() then
        local giver = StatusGiver.New(giverActor:GetActorID(), 10461)
        local buff = StatusFactoryInst:NewStatusJiaxuBuff(giver, giverActor:Get10463X())
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK)
        buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
        giverActor:GetStatusContainer():Add(buff, giverActor)
    end
end

function StatusJiaxuDebuff:AddRecoverHP()
    return self.m_skillLevel >= 2
end

function StatusJiaxuDebuff:GetStatusType()
    return StatusEnum.STATUSTYPE_JIAXU_DEBUFF
end

function StatusJiaxuDebuff:Effect(actor)
    if actor then
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end
end

function StatusJiaxuDebuff:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if actor then
        if actor:IsLive() then
            if self.m_targetRecoverHp > 0 then
                local hurt = FixMul(self.m_targetRecoverHp, self.m_hurtPercent)
                local giverActor = ActorManagerInst:GetActor(self.m_giver.actorID)
                if giverActor and giverActor:IsLive() then
                    local hurtMul = giverActor:Get10463YPercent()
                    if hurtMul > 0 then
                        hurt = FixAdd(hurt, FixMul(hurt, hurtMul))
                    end

                    if hurt > self.m_maxHurt then
                        hurt = self.m_maxHurt
                    end

                    local statusHP = StatusFactoryInst:NewStatusDelayHurt(self.m_giver, FixMul(-1, hurt), BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
                    actor:GetStatusContainer():Add(statusHP, giverActor)
                end
            end
        end
    end
end

function StatusJiaxuDebuff:OnOwnerDie(target)
    if self.m_skillLevel >= 5 then
        local giverActor = ActorManagerInst:GetActor(self.m_giver.actorID)
        if giverActor and giverActor:IsLive() then
            local nextTarget = self:SelectTarget(giverActor)
            if nextTarget and nextTarget:IsLive() then
                local jiaxuDebuff = StatusFactoryInst:NewStatusJiaxuDebuff(self.m_giver, self.m_skillTime, self.m_maxHurt, self.m_hurtRadius, self.m_intervalHurt, self.m_skillLevel, self.m_copyRadius, self.m_hurtPercent, self.m_effect)
                nextTarget:GetStatusContainer():Add(jiaxuDebuff, giverActor)
            end
        end
    end
end

function StatusJiaxuDebuff:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)

    if self.m_leftMS > 0 then
        self.m_intervalTime = FixSub(self.m_intervalTime, deltaMS)
        if self.m_intervalTime <= 0 then
            self.m_intervalTime = FixAdd(self.m_intervalTime, 1000)
            self:HurtOtherFriend(actor)
        end

        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    self:ClearEffect(actor)

    return StatusEnum.STATUSCONDITION_END
end

function StatusJiaxuDebuff:IsPositive()
    return false
end

function StatusJiaxuDebuff:AddTargetRecoverHp(recoverHP)
    self.m_targetRecoverHp = FixAdd(self.m_targetRecoverHp, recoverHP)
end

function StatusJiaxuDebuff:HurtOtherFriend(actor)
    local giverActor = ActorManagerInst:GetActor(self.m_giver.actorID)
    if not giverActor or not giverActor:IsLive() then
        return
    end

    local skillCfg = giverActor:Get10462SkillCfg()
    if not skillCfg then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local actorPos = actor:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(actor, tmpTarget, true) then
                return
            end

            local targetID = tmpTarget:GetActorID()
            if not IsInCircle(actorPos, self.m_hurtRadius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local judge = Formular.AtkRoundJudge(giverActor, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(giverActor, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_intervalHurt)
            if injure > 0 then
                local statusHP = StatusFactoryInst:NewStatusDelayHurt(self.m_giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
                tmpTarget:GetStatusContainer():Add(statusHP, giverActor)
            end
        end
    )
end

function StatusJiaxuDebuff:SelectTarget(performer)
    local minHP = 999999
    local newTarget = false
    local ctlBattle = CtlBattleInst
    local battleLogic = CtlBattleInst:GetLogic()
    local performerPos = performer:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(performerPos, self.m_copyRadius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local targetHp = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if targetHp < minHP then
                minHP = targetHp
                newTarget = tmpTarget
            end
        end
    )

    if newTarget then
        return newTarget
    end
    return nil
end


return StatusJiaxuDebuff 