local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local FixVecConst = FixVecConst
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR
local RotateAroundY = SkillRangeHelper.RotateAroundY
local FixRand = BattleRander.Rand
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local StateInterface = require "GameLogic.Battle.ActorState.StateInterface"
local SimpleMoveState = BaseClass("SimpleMoveState", StateInterface)

function SimpleMoveState:__init(selfActor)
    self.m_destPos = false
    self.m_destDir = false
    self.m_velocity = false
    self.m_avoidObsFrame = 0
    self.m_tmpPos = FixVecConst.zero()
    self.m_tmpIntersectsPos = FixVecConst.zero()
end

function SimpleMoveState:GetStateID()
    return BattleEnum.ActorState_MOVE
end

function SimpleMoveState:SetParam(whatParam, ...)
    if whatParam == BattleEnum.StateParam_MOVE_POS then
        self.m_destPos, self.m_destDir = ...
        self:OnChangeDestination()
    elseif whatParam == BattleEnum.StateParam_RIDE then
        local anim = ...
        if anim then
            self.m_selfActor:PlayAnim(BattleEnum.ANIM_RIDE_WALK)
        else
            self.m_selfActor:PlayAnim(BattleEnum.ANIM_MOVE)
        end
    end
end

function SimpleMoveState:GetParam(whatParam)
    if whatParam == BattleEnum.StateParam_MOVE_POS then
        return self.m_destPos
    end
end

function SimpleMoveState:Start(...)
    self.m_execState = BattleEnum.EventHandle_CONTINUE
    self.m_destPos, self.m_destDir = ...
    self.m_velocity = FixVecConst.zero()
    self:OnChangeDestination()
    self.m_selfActor:PlayAnim(BattleEnum.ANIM_MOVE)

    return true
end

function SimpleMoveState:End()
    -- self.m_selfActor:GetMoveHelper():Stop()
    self.m_execState = BattleEnum.EventHandle_END
end

function SimpleMoveState:Update(deltaMS)
    if self.m_execState == BattleEnum.EventHandle_END then
        return
    end

    if not self.m_selfActor then
        self.m_execState = BattleEnum.EventHandle_END
        return
    end

    if self.m_selfActor:IsPause() then
        -- self.m_selfActor:GetMoveHelper():Disable()
        return
    end

    if not self.m_selfActor:CanMove() then
        -- self.m_selfActor:GetMoveHelper():Disable()
        return
    end

    local selfPos = self.m_selfActor:GetPosition()

    local leftDisSqr = (self.m_destPos - selfPos):SqrMagnitude()

    local speed = self.m_selfActor:GetMoveSpeed()
    local deltaDis = FixMul(speed, FixDiv(deltaMS, 1000))
    local deltaDisSqr = FixMul(deltaDis, deltaDis)

    local battlelogic = CtlBattleInst:GetLogic()

    if leftDisSqr <= deltaDisSqr then
        self.m_selfActor:SetPosition(self.m_destPos)
        local tmpPosY = battlelogic:GetZoneHeight(self.m_destPos)
        self.m_selfActor:SetPosY(tmpPosY)

        self.m_execState = BattleEnum.EventHandle_END
        return        
    end

    local targetPos0 = self.m_destPos:Clone()
    targetPos0.y = 0

    local selfPos0 = selfPos:Clone()
    selfPos0.y = 0
    
    self.m_avoidObsFrame = FixAdd(self.m_avoidObsFrame, 1)
    if self.m_avoidObsFrame >= 2 then
        self.m_avoidObsFrame = 0
        local force = self:Seek(selfPos0, targetPos0, deltaDis)

        self.m_velocity = self.m_velocity + force
        self.m_velocity = self:Truncate(self.m_velocity, deltaDis)
    end

    local currPos = selfPos + self.m_velocity

    local pathHandler = CtlBattleInst:GetPathHandler()
   
    if pathHandler and battlelogic:IsPathHandlerHitTest(self.m_selfActor) then
        local hitPos = pathHandler:HitTest(selfPos0.x, 0, selfPos0.z, currPos.x, 0, currPos.z)
        if hitPos then

        -- print('- ----------- hit ', self.m_selfActor:GetWujiangID(), self.m_selfActor:GetActorID(), hitPos.x, hitPos.z, ' || ',
        --         selfPos0.x, selfPos0.z, ' --> ', currPos.x, currPos.z)
            currPos.x = hitPos.x
            currPos.z = hitPos.z
        end
    end

    self.m_selfActor:SetPosition(currPos)
    local tmpPosY = battlelogic:GetZoneHeight(currPos)
    self.m_selfActor:SetPosY(tmpPosY)

    self.m_selfActor:SetForward(self.m_velocity)
    
    -- self.m_selfActor:GetMoveHelper():Enable()
    -- self.m_selfActor:GetMoveHelper():SetSpeed(speed)
end

function SimpleMoveState:OnChangeDestination()
   
end


function SimpleMoveState:AnimateHurt()
    return true
end

function SimpleMoveState:AnimateDeath()
    return true
end

function SimpleMoveState:OnAttrChg(attr, oldVal, newVal)
    if attr == ACTOR_ATTR.FIGHT_MOVESPEED then
        self.m_selfActor:SyncMoveAnimSpeed()
    end
end

function SimpleMoveState:Truncate(vec, m)
    if vec:SqrMagnitude() > FixMul(m, m) then
        return FixNormalize(vec) * m
    end
    return vec
end

function SimpleMoveState:Seek(selfPos0, targetPos0, deltaDis)

    local steering = self:DoSeek(selfPos0, targetPos0, deltaDis) 
    
    local avoidForce = self:DoAvoidObstacle(selfPos0, targetPos0, deltaDis)
    if avoidForce then     
        steering:Add(avoidForce)
    end

    return steering
end

function SimpleMoveState:DoSeek(selfPos0, targetPos0, deltaDis)
    local desired = FixNormalize(targetPos0 - selfPos0) * deltaDis
    desired:Sub(self.m_velocity)
    return desired
end

function SimpleMoveState:DoAvoidObstacle(selfPos0, targetPos0, deltaDis)    
    if ActorUtil.IsAnimal(self.m_selfActor) then
        return nil
    end

    self.m_tmpPos:SetXYZ(0, 0, 0)

    local avoidForce = self.m_tmpPos
    local dir = FixNormalize(self.m_velocity)

    local ahead1 = selfPos0 + dir * (FixMul(deltaDis, 6))
    local ahead2 = selfPos0 + dir * (FixMul(deltaDis, 3))

    local obs = self:FindMostThreateningObstacle(ahead1, ahead2)
    if obs then
        
        local obsPosi = obs:GetPosition()
        ahead2:SetXYZ(obsPosi.x, 0, obsPosi.z)      -- 复用，减少内存

        local obsPos0 = ahead2

        local toCenter = FixNormalize(obsPos0 - selfPos0)
        if toCenter:Dot(dir) > 0.85 then
            local randVal = FixMod(FixRand(), 2)
            if randVal == 0 then
                avoidForce = RotateAroundY(dir, -60)
            else
                avoidForce = RotateAroundY(dir, 60)
            end
        else
            avoidForce = FixNormalize(ahead1 - obsPos0) 
        end
        
        avoidForce:Mul(2)
    end

    return avoidForce
end

function SimpleMoveState:FindMostThreateningObstacle(ahead1, ahead2)
    local mostThreatenObs = nil
    local mostThreatenDisSqr = 9999999
    local selfPos = self.m_selfActor:GetPosition()

    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:GetActorID() == self.m_selfActor:GetActorID() then
                return
            end

            if not tmpTarget:IsLive() then
                return
            end

            local isCollision = self:LineIntersectsCircle(ahead1, ahead2, tmpTarget)
            if not isCollision then
                return
            end

            local tmpDirSqr = (selfPos - tmpTarget:GetPosition()):SqrMagnitude()
            if not mostThreatenObs or tmpDirSqr < mostThreatenDisSqr then
                mostThreatenObs = tmpTarget
                mostThreatenDisSqr = tmpDirSqr
            end
        end
    )

    return mostThreatenObs
end

function SimpleMoveState:LineIntersectsCircle(ahead1, ahead2, obstacle)
    local obPosi = obstacle:GetPosition()
    self.m_tmpIntersectsPos:SetXYZ(obPosi.x, 0, obPosi.z)

    local obsPos = self.m_tmpIntersectsPos 
    -- local obsRadius = 0.8     --obstacle:GetRadius()
    local obsRadiusSqr = 0.64 --FixMul(obsRadius, obsRadius)

    local d = ahead1 - obsPos
    if d:SqrMagnitude() <= obsRadiusSqr then
        return true
    end

    d = ahead2 - obsPos
    if d:SqrMagnitude() <= obsRadiusSqr then
        return true
    end

    return false
end

return SimpleMoveState