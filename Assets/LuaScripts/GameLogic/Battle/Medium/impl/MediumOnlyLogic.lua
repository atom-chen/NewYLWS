local BaseMedium = require("GameLogic.Battle.Medium.BaseMedium")
local Formular = Formular
local FixMath = FixMath
local FixVecConst = FixVecConst
local FixNewVector3 = FixMath.NewFixVector3
local Vector3Normalize = FixMath.Vector3Normalize
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local ActorManagerInst = ActorManagerInst
local ComponentMgr = ComponentMgr
local StatusFactoryInst = StatusFactoryInst
local MediumEnum = MediumEnum
local StatusGiver = StatusGiver
local BattleEnum = BattleEnum
local V3Impossible = FixVecConst.impossible()
local Formular = Formular



local Base = BaseMedium
local MediumOnlyLogic = BaseClass("MediumOnlyLogic", Base)

function MediumOnlyLogic:__init()
    self.m_param = MediumOnlyLogic.NewParam()
end

function MediumOnlyLogic.NewParam(tarActorID, speed, keyFrame, keyFrameCount, hurttype)
    local o = {
        targetActorID = tarActorID or 0,
        speed = speed or 0,
        keyFrame = keyFrame or 0,
        keyFrameCount = keyFrameCount or 0,
        hurttype = hurttype or BattleEnum.HURTTYPE_NONE,
    }
    return o
end

function MediumOnlyLogic:InitParam(param)
    self.m_param.targetActorID = param.targetActorID
    self.m_param.speed = param.speed    -- m/s
    self.m_param.keyFrame = param.keyFrame
    self.m_param.keyFrameCount = param.keyFrameCount
    self.m_param.hurttype = param.hurttype
end

function MediumOnlyLogic:OnBorn()
end

function MediumOnlyLogic:DoUpdate(deltaMS)
    local owner = self:GetOwner()
    if not owner then
        self:Over()
        return
    end

    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        self:Over()
        return
    end

    local vTargetCenterPos = target:GetPosition()
    if vTargetCenterPos == V3Impossible then
        self:Over()
        return
    end

    local moveDis = FixMul(FixDiv(deltaMS, 1000), self:GetSpeed())   
    local forward = vTargetCenterPos - self:GetPosition()
    local disSqr = forward:SqrMagnitude()
    local nNewMoveDis = FixAdd(moveDis, target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_RADIUS))
    if disSqr <= FixMul(nNewMoveDis, nNewMoveDis) then
        self:ArriveDest()
        self:Over()
        return
    end
    self:SetForward(forward)
    local deltaV = self:GetForward() * moveDis 
    self:MovePostion(deltaV, vTargetCenterPos)
end

function MediumOnlyLogic:GetSpeed()
    return self.m_param.speed
end

function MediumOnlyLogic:GetTargetPos()
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if target then
        return target:GetPosition()
    end
    return V3Impossible
end

function MediumOnlyLogic:ArriveDest()
    self:AtkOne()
end

function MediumOnlyLogic:AtkOne()
    local owner = self:GetOwner()
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if owner and target then
        local injure = Formular.CalcInjure(owner, target, self.m_param.keyFrameCount)
        local st = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(-1, injure), self.m_param.hurttype, 
                                                            BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, self.m_param.keyFrameCount)
        if st then
            target:GetStatusContainer():Add(st)
        end
    end
end

return MediumOnlyLogic