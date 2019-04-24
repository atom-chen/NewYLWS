local BaseMedium = require("GameLogic.Battle.Medium.BaseMedium")
local MediumEnum = MediumEnum
local ACTOR_ATTR = ACTOR_ATTR
local StatusGiver = StatusGiver
local FixMath = FixMath
local FixVecConst = FixVecConst
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local V3Impossible = FixVecConst.impossible()
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local ActorManagerInst = ActorManagerInst
local ComponentMgr = ComponentMgr

local LinearFlyToTargetMedium = BaseClass("LinearFlyToTargetMedium", BaseMedium)
function LinearFlyToTargetMedium:__init()
    self.m_param = false
    self.m_interval = 0
    self.m_start = false
end

function LinearFlyToTargetMedium.NewParam(targetActorID, speed, keyFrame, keyFrameCount, delay)
    local o = {
        targetActorID = targetActorID or 0,
        speed = speed or 0,
        keyFrame = keyFrame or 0,
        keyFrameCount = keyFrameCount or 0,
        delay = delay or 0,
    }
    return o
end

function LinearFlyToTargetMedium:InitParam(param)
    if not self.m_param then
        self.m_param = LinearFlyToTargetMedium.NewParam()
    end

    if param then
        self.m_param.targetActorID  = param.targetActorID or 0
        self.m_param.speed  = param.speed or 1
        self.m_param.keyFrame  = param.keyFrame or 0
        self.m_param.keyFrameCount = param.keyFrameCount or 0
        self.m_param.delay  = param.delay or 0  --todo ms
        self.m_param.varSpeed = param.varSpeed or 1
        self.m_param.hurtType = param.hurtType or 0
    end
end


function LinearFlyToTargetMedium:DoUpdate(deltaMS)

    self.m_param.delay = FixSub(self.m_param.delay, deltaMS)
    if self.m_param.delay > 0 then
        return
    end

    local owner = self:GetOwner()
    if not owner or not owner:IsLive() then
        self:Over()
        return 
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        self:Over()
        return
    end

    local deltaS = FixDiv(deltaMS, 1000)
    self.m_param.speed = FixAdd(self.m_param.speed, FixMul(deltaS, self.m_param.varSpeed))
    
    local moveDis = FixMul(deltaS, self.m_param.speed) 
    local dir = target:GetPosition() - self.m_position
    dir.y = 0

    local disSqr = dir:SqrMagnitude()
    local targetRadius = target:GetRadius()

    if disSqr > FixMul(targetRadius, targetRadius) then
        local deltaV = FixNormalize(dir)
        self:SetNormalizedForward_OnlyLogic(deltaV)

        deltaV:Mul(moveDis)       
        self:MovePosition_OnlyLogic(deltaV)
        self:OnMove(dir)

        local middlePoint = target:GetMiddlePoint()
        if middlePoint then
            self:LookatTransformOnlyShow(middlePoint)
        end
        self:MoveOnlyShow(moveDis)
    else
        self:ArriveDest()
        self:Over()
        return
    end
end


function LinearFlyToTargetMedium:GetSpeed()
    return self.m_param.speed
end

function LinearFlyToTargetMedium:ArriveDest()
end

function LinearFlyToTargetMedium:OnMove(dir)
end

return LinearFlyToTargetMedium
