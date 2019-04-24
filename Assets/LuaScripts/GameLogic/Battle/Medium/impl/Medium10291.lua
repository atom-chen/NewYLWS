local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local IsInRect = SkillRangeHelper.IsInRect
local FixNormalize = FixMath.Vector3Normalize
local IsInCircle = SkillRangeHelper.IsInCircle

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10291 = BaseClass("Medium10291", LinearFlyToPointMedium)

function Medium10291:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)

    self.m_injure = param.injure
end

function Medium10291:ArriveDest()
    self:Hurt()
    BattleCameraMgr:Shake()
end

function Medium10291:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local logic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(self.m_param.targetPos, 1.5, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local giver = StatusGiver.New(performer:GetActorID(), 10291)
            local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, self.m_injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                judge, self.m_param.keyFrame)
            self:AddStatus(performer, tmpTarget, status)

            local giver = StatusGiver.New(performer:GetActorID(), 10291)
            local stunBuff = factory:NewStatusStun(giver, FixIntMul(self.m_skillBase:D(), 1000))
            self:AddStatus(performer, tmpTarget, stunBuff)
        end
    )
end

-- return 是否到达目的地
function Medium10291:MoveToTarget(deltaMS)
    if self.m_param.targetPos == nil then
        -- print("self.m_param.targetPos nil")
        return
    end

    local deltaS = FixDiv(deltaMS, 1000)
    self.m_param.speed = FixAdd(self.m_param.speed, FixMul(deltaS, self.m_param.varSpeed))
    
    local moveDis = FixMul(deltaS, self.m_param.speed) 
    local dir = self.m_param.targetPos - self.m_position
    -- dir.y = 0
    local leftDistance = dir:Magnitude()

    if dir:IsZero() then
        return true
    else
        local deltaV = FixNormalize(dir) 
        deltaV:Mul(moveDis) 

        self:SetForward(dir)
        self:MovePosition(deltaV)
        self:OnMove(dir)

        self.m_position.y = FixSub(self.m_position.y, moveDis)
        if FixSub(self.m_position.y, self.m_param.targetPos.y) <= 0.1 then
            return true
        end
    end

    return false
end

return Medium10291