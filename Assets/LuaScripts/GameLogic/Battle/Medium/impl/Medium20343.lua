local StatusGiver = StatusGiver
local FixMath = FixMath
local FixVecConst = FixVecConst
local FixNormalize = FixMath.Vector3Normalize
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local StatusFactoryInst = StatusFactoryInst

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium20343 = BaseClass("Medium20343", LinearFlyToTargetMedium)

function Medium20343:ArriveDest()
    self:Hurt()
end

function Medium20343.CreateParam(targetActorID, keyFrame, speed, hurtType)
    local p = {
        targetActorID = targetActorID,
        keyFrame = keyFrame,
        speed = speed,
        hurtType = hurtType
    }
    return p
end

function Medium20343:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, self.m_param.hurtType, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end
    
    local giver = StatusGiver.New(performer:GetActorID(), 20343)
    local stunBuff = StatusFactoryInst:NewStatusStun(giver, FixIntMul(self.m_skillBase:A(), 1000))
    self:AddStatus(performer, target, stunBuff)
    local injure = Formular.CalcInjure(performer, target, self:GetSkillCfg(), self.m_param.hurtType, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), self.m_param.hurtType, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)
    end
end


function Medium20343:DoUpdate(deltaMS)

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

return Medium20343