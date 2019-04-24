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

local LinearFlyToPointMedium = BaseClass("LinearFlyToPointMedium", BaseMedium)
function LinearFlyToPointMedium:__init()
    self.m_param = false
    self.m_interval = 0
    self.m_start = false
end

function LinearFlyToPointMedium.NewParam(targetPos, speed, keyFrame, keyFrameCount, delay)
    local o = {
        targetPos = targetPos or FixNewVector3(),
        speed = speed or 0,
        keyFrame = keyFrame or 0,
        keyFrameCount= keyFrameCount or 0,
        delay = delay or 0,
    }
    return o
end

function LinearFlyToPointMedium:InitParam(param)
    if not self.m_param then
        self.m_param = LinearFlyToPointMedium.NewParam()
    end

    if param then
        if param.targetPos then
            self.m_param.targetPos:SetXYZ(param.targetPos:GetXYZ())
        end

        -- self.m_param.targetActorID  = param.targetActorID or 0
        self.m_param.speed  = param.speed or 1
        self.m_param.keyFrame  = param.keyFrame or 0
        self.m_param.keyFrameCount  = param.keyFrameCount or 0
        self.m_param.delay  = param.delay or 0  --todo ms
        self.m_param.varSpeed = param.varSpeed or 1
    end
end


function LinearFlyToPointMedium:DoUpdate(deltaMS)

    self.m_param.delay = FixSub(self.m_param.delay, deltaMS)
    if self.m_param.delay > 0 then
        return
    end

  
    
   --[[  if self.m_param.targetActorID > 0 then
        local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
        if not target or not target:IsLive() then
            self:Over()
            return
        end
    end ]]

    local owner = self:GetOwner()
    if not owner or not owner:IsLive() then
        self:Over()
        return 
    end

    -- todo check
    if self:GetTargetPos() == V3Impossible then
        self:Over()
        return
    end

    if self:MoveToTarget(deltaMS) then
        self:ArriveDest()
        self:Over()
        return
    end
    
end

-- return 是否到达目的地
function LinearFlyToPointMedium:MoveToTarget(deltaMS)
    if self.m_param.targetPos == nil then
        -- print("self.m_param.targetPos nil")
        return
    end

    local deltaS = FixDiv(deltaMS, 1000)
    self.m_param.speed = FixAdd(self.m_param.speed, FixMul(deltaS, self.m_param.varSpeed))
    
    local moveDis = FixMul(deltaS, self.m_param.speed) 
    local dir = self.m_param.targetPos - self.m_position
    dir.y = 0
    local leftDistance = dir:Magnitude()

    if dir:IsZero() then
        return true
    else
        local deltaV = FixNormalize(dir) 
        deltaV:Mul(moveDis)

        self:SetForward(dir)
        self:MovePosition(deltaV)
        self:OnMove(dir)

        if leftDistance < moveDis then
            return true
        end
    end

    return false
end

function LinearFlyToPointMedium:GetSpeed()
    return self.m_param.speed
end

function LinearFlyToPointMedium:GetTargetPos()
    return self.m_param.targetPos
end

function LinearFlyToPointMedium:ArriveDest()
end

function LinearFlyToPointMedium:OnMove(dir)
end

return LinearFlyToPointMedium
