local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local FixNormalize = FixMath.Vector3Normalize

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium10392 = BaseClass("Medium10392", LinearFlyToTargetMedium)

local MediumState = {
    Forward=1,
    Back = 2,
}

function Medium10392:__init()
    self.m_mediumState = MediumState.Forward
    self.m_targetChgDis = 0
    self.m_skillLevel = 0
end


function Medium10392:DoUpdate(deltaMS)
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
    local dir = nil
    if self.m_mediumState == MediumState.Forward then
        dir = target:GetPosition() - self.m_position
    else
        dir = owner:GetPosition() - self.m_position
    end
    dir.y = 0

    local disSqr = dir:SqrMagnitude()
    local targetRadius = FixAdd(target:GetRadius(), target:GetRadius())
   
    if disSqr > FixMul(targetRadius, targetRadius) then
        local deltaV = FixNormalize(dir)
        if self.m_mediumState == MediumState.Forward then
            self:SetNormalizedForward_OnlyLogic(deltaV)
        else
            self:SetNormalizedForward_OnlyLogic(deltaV)
        end

        deltaV:Mul(moveDis)       
        self:MovePosition_OnlyLogic(deltaV)
        self:OnMove(dir)

        local middlePoint = target:GetMiddlePoint()
        if middlePoint then
            self:LookatTransformOnlyShow(middlePoint)
        end

        if self.m_mediumState == MediumState.Back then
            target:OnBeatBack(owner, FixMul(moveDis, -1))

            if self.m_skillLevel >= 4 then
                self.m_targetChgDis = FixAdd(self.m_targetChgDis, moveDis)
                if self.m_targetChgDis >= 1 then
                    self:MakeRealHurt(owner, target)
                    self.m_targetChgDis = FixSub(self.m_targetChgDis, 1)
                end
            end
        end

        self:MoveOnlyShow(moveDis)
    else
        self:ArriveDest()
        return
    end
end

function Medium10392:MakeRealHurt(performer, target)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    
    local targetCurHp = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local injure = FixMul(targetCurHp, FixDiv(self.m_skillBase:Z(), 100))
    local maxInjure = Formular.CalcMaxHPInjure(self.m_skillBase:Z(), target, BattleEnum.MAXHP_INJURE_PRO_LEFTHP)
    if injure > maxInjure then
        injure = maxInjure
    end

    local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, 1)
    self:AddStatus(performer, target, status)
end

function Medium10392:ArriveDest()
    if self.m_mediumState == MediumState.Forward then
        local performer = self:GetOwner()
        if not performer then
            return
        end

        self:Hurt()

        local dis = (self.m_position - performer:GetPosition()):Magnitude()
        self.m_param.speed = FixDiv(dis, 0.5)

        self.m_skillLevel = self.m_skillBase:GetLevel()
        self.m_mediumState = MediumState.Back

    elseif self.m_mediumState == MediumState.Back then
        self:Over()
    end
end

function Medium10392:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        self:Over()
        return
    end
    
    local injure = Formular.CalcInjure(performer, target, self:GetSkillCfg(), BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:Y())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        local dingshenStatus = StatusFactoryInst:NewStatusDingShen(self.m_giver, 500)
        self:AddStatus(performer, target, dingshenStatus)
    end
end

return Medium10392