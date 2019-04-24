local BaseMedium = require("GameLogic.Battle.Medium.BaseMedium")
local MediumEnum = MediumEnum
local ACTOR_ATTR = ACTOR_ATTR
local StatusGiver = StatusGiver
local FixMath = FixMath
local FixVecConst = FixVecConst
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local ActorManagerInst = ActorManagerInst
local ComponentMgr = ComponentMgr
local table_insert = table.insert
local table_remove = table.remove
local V3Impossible = FixVecConst.impossible()
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst


local LinearEjectMotionMedium = BaseClass("LinearEjectMotionMedium", BaseMedium)

function LinearEjectMotionMedium:__init()
    self.m_param = false
    self.m_curEjectNum = 0
    self.m_hitedList = {}
end


function LinearEjectMotionMedium:NewParam(targetActorID, speed, keyFrame, keyFrameCount, ejectNum, discount, ejectRadiusSqr)
    local o = {
        targetActorID = targetActorID or 0,
        speed = speed or 0,
        keyFrame = keyFrame or 0,
        keyFrameCount = keyFrameCount or 0,
        ejectNum = ejectNum or 0,
        discount = discount or 0,
        ejectRadiusSqr = ejectRadiusSqr or 0,
    }
    return o
end

function LinearEjectMotionMedium:InitParam(param)
    if not self.m_param then
        self.m_param = LinearEjectMotionMedium.NewParam()
    end
    if not param then
        return
    end
    self.m_param.targetActorID = param.targetActorID
    self.m_param.speed = param.speed
    self.m_param.keyFrame = param.keyFrame
    self.m_param.keyFrameCount = param.keyFrameCount
    self.m_param.ejectNum = param.ejectNum
    self.m_param.discount = param.discount
    self.m_param.ejectRadiusSqr = param.ejectRadiusSqr
end

function LinearEjectMotionMedium:DoUpdate(deltaMS)
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
    local moveDis = FixMul(deltaMS, self:GetSpeed())        -- todo speed m/s ??
    local forward = vTargetCenterPos - self:GetPosition()
    local disSqr = forward:SqrMagnitude()
    local nNewMoveDis = FixAdd(moveDis, target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_RADIUS))
 
    if disSqr <= FixMul(nNewMoveDis, nNewMoveDis) then
        self:ArriveDest()
        self.m_curEjectNum = FixAdd(self.m_curEjectNum, 1)
        table_insert(self.m_hitedList, self.m_param.targetActorID)
        if self.m_curEjectNum >= self.m_param.ejectNum then
            self:Over()
            return
        end
        local next = self:SearchForNextTarget(vTargetCenterPos)
        if not next or next < 0 then
            self:Over()
            return
        end
        self.m_position:SetXYZ(vTargetCenterPos:GetXYZ())
        self.m_param.targetActorID = next
        vTargetCenterPos = self:GetTargetPos()
        if vTargetCenterPos == V3Impossible then
            self:Over()
            return
        end
        forward = vTargetCenterPos - self.m_position
        self:SetForward(forward)
        local deltaV = FixNormalize(forward) * moveDis 
        self:MovePostion(deltaV, vTargetCenterPos)

        self:EffectOnTheWay()
    end
end

function LinearEjectMotionMedium:SearchForNextTarget(cur_pos)

end

function LinearEjectMotionMedium:GetSpeed()
    return self.m_param.speed
end

function LinearEjectMotionMedium:GetTargetPos()
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if target then
        return target:GetPosition()
    end
    return V3Impossible
end

function LinearEjectMotionMedium:ArriveDest()
    self:AtkOne()
end

function LinearEjectMotionMedium:AtkOne()
    local owner = self:GetOwner()
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if owner and target then
        local injure = Formular.CalcInjure(owner, target, self.m_param.keyFrameCount)
        injure = FixSub(injure, FixMul(injure, FixDiv(GetCurDiscount(), 100)))
        local st = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(-1, injure), self.m_param.hurttype, 
                                                            BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, self.m_param.keyFrameCount)
        if st then
            target:GetStatusContainer():Add(st)
        end
    end
end

function LinearEjectMotionMedium:GetCurDiscount()
    return FixMul(self.m_curEjectNum, self.m_param.discount)
end

function LinearEjectMotionMedium:EffectOnTheWay()

end

return LinearEjectMotionMedium