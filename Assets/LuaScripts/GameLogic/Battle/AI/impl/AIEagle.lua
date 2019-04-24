
local AIBase = require "GameLogic.Battle.AI.AIBase"
local FixNormalize = FixMath.Vector3Normalize
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local table_insert = table.insert
local table_remove = table.remove
local SKILL_PERFORM_MODE = SKILL_PERFORM_MODE
local SKILL_CHK_RESULT = SKILL_CHK_RESULT
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local BattleEnum = BattleEnum
local ConfigUtil = ConfigUtil
local SkillPoolInst = SkillPoolInst
local ActorManagerInst = ActorManagerInst
local ACTOR_ATTR = ACTOR_ATTR

local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst

local AIEagle = BaseClass("AIEagle", AIBase)

local EagleState = {
    EagleState_Normal = 1,
    EagleState_Leave = 2,
    EagleState_Back = 3,
}

function AIEagle:__init(actor)
    self.m_isAddSpeed = false
    self.m_followOwnerInterval = 0
    self.m_atkLeftTime = false
    self.m_targetPos = false
    self.m_skillList = {}
    self.m_lastTargetID = 0
    self.m_skillID = 0
    self.m_eagleState = EagleState.EagleState_Normal
    self.m_aiType = BattleEnum.AITYPE_XILIANGEAGLE
    self.m_performSkill40073And40072 = false
end

function AIEagle:AI(deltaMS)
    local owner = ActorManagerInst:GetActor(self.m_selfActor:GetOwnerID())
    if not owner or not owner:IsLive() then
        self.m_selfActor:KillSelf()
        return
    end

    if self.m_atkLeftTime then
        if self.m_atkLeftTime > 0 then
            self.m_atkLeftTime = FixSub(self.m_atkLeftTime, deltaMS)
        end
    end
    
    local currState = self.m_selfActor:GetCurrStateID()
    
    if self.m_eagleState == EagleState.EagleState_Normal then
        local skillcfg = ConfigUtil.GetSkillCfgByID(40072)
        if skillcfg then
            local makeHurt = self.m_selfActor:GetMakeHurt()
            if makeHurt > 0 then
                local recoverHPMul = self.m_selfActor:GetRecoverMul()
                local recoverHP = FixIntMul(makeHurt, recoverHPMul)
                
                self.m_selfActor:ClearMakeHurt() 
                
                local factory = StatusFactoryInst
                local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 40072)
                local statusHP = factory:NewStatusDelayHurt(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
                owner:GetStatusContainer():Add(statusHP, self.m_selfActor)
            end
        end

        if #self.m_skillList > 0 then
            local firList = self.m_skillList[1]
            if firList then
                self.m_lastTargetID = firList.currTargetActorID
                self.m_skillID = firList.skillID
                self.m_atkLeftTime = firList.atkLeftTime
                table_remove(self.m_skillList, 1)
                self.m_selfActor:GetSkillContainer():SetNextSkillID(self.m_skillID)
                self.m_eagleState = EagleState.EagleState_Leave
                if firList.skillID == 40073 then
                    self.m_performSkill40073And40072 = true
                elseif firList.skillID == 40072 then
                    self.m_performSkill40073And40072 = false
                end
            end
        else            
            if currState == BattleEnum.ActorState_IDLE or currState == BattleEnum.ActorState_MOVE then
                self:FollowOwner(owner, deltaMS)
                
                if currState == BattleEnum.ActorState_IDLE then
                    self.m_selfActor:SetForward(owner:GetForward())
                end
            end           
        end       

    elseif self.m_eagleState == EagleState.EagleState_Leave then
        local target = ActorManagerInst:GetActor(self.m_lastTargetID)
        if not target or not target:IsLive() then
            self.m_eagleState = EagleState.EagleState_Back
            return
        end
        
        if currState == BattleEnum.ActorState_IDLE or currState == BattleEnum.ActorState_MOVE then
            local skillItem = self.m_selfActor:GetSkillContainer():GetByID(self.m_skillID)
            if skillItem then
                if self.m_performSkill40073And40072 then
                    self.m_skillID = 0
                end
                
                self:EagelPerformSkill(skillItem, target, deltaMS)
            end
    
            if self.m_atkLeftTime then
                if self.m_atkLeftTime < 0 then
                    self.m_atkLeftTime = false
                    if self.m_performSkill40073And40072 then
                        self.m_eagleState = EagleState.EagleState_Normal
                    else
                        self.m_eagleState = EagleState.EagleState_Back
                    end
                end
            else
                if currState == BattleEnum.ActorState_IDLE then
                    self.m_eagleState = EagleState.EagleState_Back
                end
            end
        end

    elseif self.m_eagleState == EagleState.EagleState_Back then
        self:FollowOwner(owner, deltaMS)

        local dir = self.m_targetPos - self.m_selfActor:GetPosition()
        dir.y = 0
        local leftDistance = dir:SqrMagnitude()
        if leftDistance <= 0.04 then            
            self.m_selfActor:SetForward(owner:GetForward())
            self.m_eagleState = EagleState.EagleState_Normal
        end        
    end 
end

function AIEagle:ChgMoveSpeed(speed)
    self.m_selfActor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MOVESPEED, speed)
end

function AIEagle:Attack(targetID, skillID, atkLeftTime)
    if skillID == 40073 then        
        table_insert(self.m_skillList, {currTargetActorID = targetID, skillID = skillID, atkLeftTime = 1500})
        table_insert(self.m_skillList, {currTargetActorID = targetID, skillID = 40072, atkLeftTime = atkLeftTime})
    else
        table_insert(self.m_skillList, {currTargetActorID = targetID, skillID = skillID, atkLeftTime = atkLeftTime})
    end
end

function AIEagle:FollowOwner(owner, deltaMS)   
    if not owner or self.m_performSkill40073And40072 then
        return
    end
    
    self.m_targetPos = owner:GetPosition()
    local dir = owner:GetForward()
    local leftDir = FixVetor3RotateAroundY(dir, -89.9)
    self.m_targetPos = self.m_targetPos + FixNormalize(leftDir)

    if self.m_followOwnerInterval == 0 or self.m_followOwnerInterval > 100 then
        self.m_followOwnerInterval = 0
        local tmpDir = self.m_selfActor:GetPosition() - self.m_targetPos
        tmpDir.y = 0
        local distance = tmpDir:SqrMagnitude()
        if distance >= 0.04 then
            self.m_selfActor:SimpleMove(self.m_targetPos)
        end
    end

    self.m_followOwnerInterval = FixAdd(self.m_followOwnerInterval, deltaMS)
end

function AIEagle:EagelPerformSkill(skillItem, target, deltaMS)
    local tmpRet = SKILL_CHK_RESULT.ERR

    local skillcfg = ConfigUtil.GetSkillCfgByID(skillItem:GetID())
    if skillcfg then    
        if self:InnerCheck(skillItem, skillcfg, true, target) then
            local skillbase = SkillPoolInst:GetSkill(skillcfg, skillItem:GetLevel())
            if skillbase then 
                tmpRet = skillbase:CheckPerform(self.m_selfActor, target)                
            end
        end
    end

    if tmpRet == SKILL_CHK_RESULT.OK then
        self:PerformSkill(target, skillItem, target:GetPosition(), SKILL_PERFORM_MODE.AI)
    else
        if self:ShouldFollowEnemy(tmpRet) then
            self:Follow(target, deltaMS)
        else
            self:TryStop(target:GetPosition())
        end
    end
end

return AIEagle