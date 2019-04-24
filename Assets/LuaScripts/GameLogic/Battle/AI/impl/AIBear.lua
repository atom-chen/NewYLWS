local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixNormalize = FixMath.Vector3Normalize
local ConfigUtil = ConfigUtil
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local SkillUtil = SkillUtil
local FixNewVector3 = FixMath.NewFixVector3
local ACTOR_ATTR = ACTOR_ATTR

local AIBase = require "GameLogic.Battle.AI.AIBase"
local AIBear = BaseClass("AIBear", AIBase)

local BearState = {
    BearState_Normal = 1,
    BearState_Back = 2,
    BearState_Gasp = 3,
}

function AIBear:__init(actor)
    self.m_currBearState = BearState.BearState_Normal
    self.m_followOwnerInterval = 0
    self.m_recoverHPTimeDelta = 0

    self.m_aiType = BattleEnum.AITYPE_XILIANGBEAR

    self.m_maxHP = self.m_selfActor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)

    self.m_40081skillItem = self.m_selfActor:GetSkillContainer():GetPassiveByID(40081)
    self.m_40081skillCfg = ConfigUtil.GetSkillCfgByID(40081)
    
    self.m_40082skillItem = self.m_selfActor:GetSkillContainer():GetPassiveByID(40082)
    self.m_40082skillCfg = ConfigUtil.GetSkillCfgByID(40082)
    
    self.m_callByOwner = false
    self.m_ownerOriginalPos = false
    self.m_shouldPerform40082Skill = true
end

function AIBear:__delete()
    self.m_40081skillCfg = nil
    self.m_40081skillItem = nil
end

function AIBear:CanAI()
    if self.m_selfActor == nil then
        return false
    end

    if self.m_selfActor:IsLive() == false then
        return false
    end

    if self.m_selfActor:CanAction() == false then
        return false
    end

    return true
end

function AIBear:Attack(targetID)
    self.m_currTargetActorID = targetID
    self.m_callByOwner = true
end

function AIBear:AI(deltaMS)
    -- 特殊状态 并且训熊师没有死亡才会回血
    if not self:CheckSpecialState(deltaMS) then
        if self.m_currBearState == BearState.BearState_Back or self.m_currBearState == BearState.BearState_Gasp then
            local owner = ActorManagerInst:GetActor(self.m_selfActor:GetOwnerID())
            if owner and owner:IsLive() then 
                self:RecoverHP(deltaMS)
            end
        end
        return
    end

    if not self:CanAI() then
        return
    end

    local currState = self.m_selfActor:GetCurrStateID()

    if self.m_currBearState == BearState.BearState_Normal then
        local owner = ActorManagerInst:GetActor(self.m_selfActor:GetOwnerID())
        if not owner or not owner:IsLive() then
            -- 训熊师死后，只会在normal状态才会悲鸣，而且只会悲鸣一次
            if self.m_shouldPerform40082Skill and self.m_40082skillItem then
                self:PerformSkill(self.m_selfActor, self.m_40082skillItem, self.m_selfActor:GetPosition(), SKILL_PERFORM_MODE.AI)
                self.m_shouldPerform40082Skill = false

                local curPhyDef = self.m_selfActor:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
                local chgPhyDef = FixIntMul(curPhyDef, FixDiv(self.m_40082skillCfg.A, 100))
                self.m_selfActor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
                return
            end
        end

        -- 如果训熊师死亡，不会再检测血量；如果已经进入 喘息状态，不会改变当前喘息状态，持续回血
        if owner and owner:IsLive() then 
            self:CheckCurHPPercent(deltaMS)
        end

        if self.m_callByOwner then -- 为了让熊在跑的过程中，被攻击时不会明显的停顿,并且训熊师下命令之后死亡，依然会释放技能
            local target = ActorManagerInst:GetActor(self.m_currTargetActorID)
            if not target or not target:IsLive() then
                self.m_callByOwner = false
                return
            end
      
            local dir = target:GetPosition() - self.m_selfActor:GetPosition()
            dir.y = 0
            local distance = dir:Magnitude() - self.m_selfActor:GetRadius()
            if distance > 0.2 then
                self.m_selfActor:SimpleMove(target:GetPosition())
                return
            end
        end

        if currState == BattleEnum.ActorState_IDLE or currState == BattleEnum.ActorState_MOVE then
            if self.m_currTargetActorID == 0 then
                local tmpTarget = self:FindTarget()
                if not tmpTarget then
                    self:OnNoTarget()
                else
                    self:SetTarget(tmpTarget:GetActorID())
                end  
            end
    
            if self.m_currTargetActorID ~= 0 then
                local target = ActorManagerInst:GetActor(self.m_currTargetActorID)
                if not target or not target:IsLive() then
                    self:SetTarget(0)
                    return
                end
    
                local p = target:GetPosition()
                local selectSkill = false
                if self.m_callByOwner then
                    self.m_callByOwner = false
                    self.m_selfActor:GetSkillContainer():SetNextSkillID(40083)
                    local chkRet = false 
                    selectSkill, chkRet = self:SelectSkill(target)
                    if selectSkill and chkRet then
                        if chkRet.newTarget then
                            self:SetTarget(chkRet.newTarget:GetActorID())
                            target = chkRet.newTarget
                        end
                        p = chkRet.pos
                    end
                end

                local normalRet = SKILL_CHK_RESULT.ERR
                if not selectSkill then
                    normalRet, selectSkill = self:SelectNormalSkill(target)
                end

                if selectSkill then
                    self.m_callByOwner = false
                    self:PerformSkill(target, selectSkill, p, SKILL_PERFORM_MODE.AI)
                else
                    if normalRet == SKILL_CHK_RESULT.TARGET_TYPE_UNFIT then
                        self:SetTarget(0)
                    end
    
                    if self:ShouldFollowEnemy(normalRet) then
                        self:Follow(target, deltaMS)
                    else
                        self:TryStop(target:GetPosition())
                    end
                end
            end
        end

    elseif self.m_currBearState == BearState.BearState_Back then   
        local owner = ActorManagerInst:GetActor(self.m_selfActor:GetOwnerID())
        -- if owner and owner:IsLive() and not self.m_ownerOriginalPos then
        --     self.m_ownerOriginalPos = owner:GetPosition() -- 目的 防止熊在跑到训熊师背后过程中，训熊师死亡
        -- end

        self:CheckCurHPPercent(deltaMS)

        if owner and owner:IsLive() then -- 暂定
            self:BackToOwner(owner, deltaMS)
        else
            self.m_currBearState = BearState.BearState_Normal
            return
        end
        
        self:RecoverHP(deltaMS)

    elseif self.m_currBearState == BearState.BearState_Gasp then -- 喘息
        self:CheckCurHPPercent(deltaMS)
        self:RecoverHP(deltaMS)
    end
end

function AIBear:BackToOwner(owner, deltaMS)
    if not owner or not owner:IsLive() then -- 下帧切到normal状态
        return
    end

    local dir = owner:GetForward()
    local leftDir = FixVetor3RotateAroundY(dir, -160)
    local targetPos = FixNormalize(leftDir) *3
    targetPos:Add(owner:GetPosition())

    local movehelper = self.m_selfActor:GetMoveHelper()
    if movehelper then
        local pathHandler = CtlBattleInst:GetPathHandler()
        if pathHandler then
            local x,y,z = self.m_selfActor:GetPosition():GetXYZ()
            local x2, y2, z2 = targetPos:GetXYZ()
            local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
            if hitPos then
                targetPos:SetXYZ(hitPos.x , self.m_selfActor:GetPosition().y, hitPos.z)
            end
        end
    end

    local dir = targetPos - self.m_selfActor:GetPosition()
    dir.y = 0
    local disSqr = dir:SqrMagnitude()
    
    if disSqr <= 0.01  then
        self.m_currBearState = BearState.BearState_Gasp
        
        self.m_selfActor:AddGaspCount()
        if owner and owner:IsLive() then
            self.m_selfActor:SetForward(owner:GetForward())
        else
            self.m_selfActor:SetForward(self.m_selfActor:GetForward() * -1)
        end

        self.m_selfActor:PlayAnim("skill3") -- 40081
        return
    end

    if self.m_followOwnerInterval == 0 or self.m_followOwnerInterval > 100 then
        self.m_followOwnerInterval = 0
        self.m_selfActor:SimpleMove(targetPos)
    end
    self.m_followOwnerInterval = FixAdd(self.m_followOwnerInterval, deltaMS)
end

function AIBear:RecoverHP(deltaMS)
    if not self.m_40081skillItem then
        return
    end

    if not self.m_40081skillCfg then
        return
    end
    
    self.m_recoverHPTimeDelta = FixAdd(deltaMS, self.m_recoverHPTimeDelta)

    if self.m_recoverHPTimeDelta >= 1000 then
        self.m_recoverHPTimeDelta = 0

        local factory = StatusFactoryInst
        local recoverHP = FixIntMul(FixDiv(SkillUtil.X(self.m_40081skillCfg, 1), 100), self.m_maxHP)
    
        local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 40081)
        local statusHP = factory:NewStatusDelayHurt(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
        self.m_selfActor:GetStatusContainer():Add(statusHP, self.m_selfActor)
    end
end

function AIBear:CheckCurHPPercent(deltaMS)
    if not self.m_40081skillItem then
        return
    end 

    if not self.m_40081skillCfg then
        return
    end
    
    local curHP = self.m_selfActor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    if curHP >= self.m_maxHP then
        -- 喘息gasp -> normal
        self.m_currBearState = BearState.BearState_Normal
        return
    end

    if self.m_selfActor:GetGaspCount() < 1 and FixDiv(FixSub(self.m_maxHP, curHP), self.m_maxHP) >= FixDiv(self.m_40081skillCfg.A, 100) then
        if self.m_currBearState ~= BearState.BearState_Gasp then
            -- normal -> back
            self.m_currBearState = BearState.BearState_Back
        end
    end
end

function AIBear:ShowableInCamera()
    if self.m_currBearState == BearState.BearState_Escape then
        return false
    else
        return true
    end
end

return AIBear