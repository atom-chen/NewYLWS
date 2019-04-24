local BaseMedium = require("GameLogic.Battle.Medium.BaseMedium")
local ParambolaFlyToPointMedium = require("GameLogic.Battle.Medium.impl.ParambolaFlyToPointMedium")
local MediumEnum = MediumEnum
local StatusGiver = StatusGiver
local FixMath = FixMath
local FixVecConst = FixVecConst
local FixNewVector3 = FixMath.NewFixVector3

local ComponentMgr = ComponentMgr
local LogError = Logger.LogError
local Base = ParambolaFlyToPointMedium
-- 表现 曲线飞向指定点
local BezierFlyToPointMedium = BaseClass("BezierFlyToPointMedium", ParambolaFlyToPointMedium)

function BezierFlyToPointMedium:__init()
    self.pointsNum = 0
end

function BezierFlyToPointMedium:CreateCurve() 
    -- TODO Bezier Curve
end

function BezierFlyToPointMedium:GetPointsNum() 
    return self.pointsNum
end

function BezierFlyToPointMedium:InitCurve(tranComp, hexMap) 
    if not tranComp or not hexMap then
        return
    end

    self.pointsNum = self:CalPointsNum()
    --assert(self.pointsNum >= 4)
    if self.pointsNum < 4 then
        LogError("error pointsNum" .. self.pointsNum)
        return
    end
    if self.tempVecLength < self.pointsNum + 2 then
        self.tempVecList[self.tempVecLength + 1] = FixNewVector3()
        self.tempVecList[self.tempVecLength + 2] = FixNewVector3()
        self.tempVecLength = self.pointsNum + 2
    end

    self:SetPoints(hexMap, tempVecList, self.pointsNum)

    for i = self.pointsNum, self.tempVecLength do
        self.tempVecList[i]:SetXYZ(self.tempVecList[self.pointsNum - 1]:GetXYZ())
    end
    self.curve:Init(tranComp, tempVec,self.pointsNum + 2)
    self.curve:DoCurve(0)
end

function BezierFlyToPointMedium:SetPoints(hexMap, points, length)
    --ovvrride布点
end

function BezierFlyToPointMedium:CalPointsNum()
    --override时注意：一定不能小于4
    return 4
end

return BezierFlyToPointMedium