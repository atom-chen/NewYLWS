local BaseMedium = require("GameLogic.Battle.Medium.BaseMedium")
local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local MediumEnum = MediumEnum
local StatusGiver = StatusGiver
local FixMath = FixMath
local FixVecConst = FixVecConst
local FixNewVector3 = FixMath.NewFixVector3
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local ActorManagerInst = ActorManagerInst
local ComponentMgr = ComponentMgr
local Base = LinearFlyToPointMedium

-- 表现 曲线飞向指定点
local ParambolaFlyToPointMedium = BaseClass("ParambolaFlyToPointMedium", LinearFlyToPointMedium)
function ParambolaFlyToPointMedium:__init()
    self.m_vStartPos = FixNewVector3()
    self.m_nTotalMove2D = 0
    self.curve = self:CreateCurve()
    self.tempVecLength = 4
    self.tempVecList = {} 
end

function ParambolaFlyToPointMedium:CreateCurve() 
    -- TODO 
end

function ParambolaFlyToPointMedium:__delete() 
    self.curve:Reset()
end

function ParambolaFlyToPointMedium:OnBorn() 
    Base.OnBorn(self)
    self.m_vStartPos = FixNewVector3()
    self.m_nTotalMove2D = (self:GetTargetPos() - self.m_vStartPos):Magnitude2D()
    if self.m_componet then
        --TODO InitCurve
    end
end

function ParambolaFlyToPointMedium:InitCurve(tranComp, hexMap)  --todo fixmath ?
    tempVecList[1] = hexMap:LogicToPixel(self.m_vStartPos)
    tempVecList[2] = hexMap.LogicToPixel((self.m_vStartPos + self:GetTargetPos()) / 2 + FixNewVector3(0, self:GetMaxHeight(), 0))
    tempVecList[3] = hexMap.LogicToPixel(self:TargetPos())
    tempVecList[4] = hexMap.LogicToPixel(self:TargetPos())
    curve:Init(tranComp, tempVecList, tempVecLength)
    curve:DoCurve(0)
end

function ParambolaFlyToPointMedium:MoveToTarget(deltaMS) 
    local forward = self:GetTargetPos() - self.m_postion
    forward.y = 0
    local disSqr2D = forward:SqrMagnitude2D()
    local moveDis2D = FixMul(self.m_param.speed, deltaMS)
    local nNewMoveDis2D = moveDis2D

    if self.m_param.targetActorID > 0 then
        local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
        if target then
            nNewMoveDis2D = FixAdd(nNewMoveDis2D, target:GetData().GetAttrValue(ACTOR_ATTR.FIGHT_RADIUS))
        end
    end

    if disSqr2D <= FixMul(nNewMoveDis2D, nNewMoveDis2D) then
        return true
    end

    local deltaV = FixMath.Vector3Normalize(forward)
    deltaV:Mul(moveDis2D) 
    self:MovePosition_OnlyLogic(deltaV, self:GetTargetPos())
    self:SetForward_OnlyLogic(deltaV)

    -- 计算表现上的垂直高度
    DoUpdate_OnlyShow()
    return false
end

function ParambolaFlyToPointMedium:DoUpdate_OnlyShow()
    if self.m_nTotalMove2D == 0 then
        return
    end
    local nMove2D = (self:GetPostion() - self.m_vStartPos):Magnitude2D()
    self.curve:DoCurve(FixDiv(nMove2D, self.m_nTotalMove2D))
end

function ParambolaFlyToPointMedium:GetMaxHeight()
    local height = FixDiv(FixMul(1500, self.m_nTotalMove2D), 5000) -- TODO ?
    if height <= 0 then
        return 1
    end
    return height
end

return ParambolaFlyToPointMedium

