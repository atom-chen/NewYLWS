local FixMul = FixMath.mul
local FixAdd = FixMath.add
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local table_insert = table.insert
local FixRand = BattleRander.Rand
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixNormalize = FixMath.Vector3Normalize

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium10642 = BaseClass("Medium10642", LinearFlyToTargetMedium)

local MediumState = {
    Normal = 1,
    Hurt = 2
}

function Medium10642:__init()
    self.m_ejectionCount = 0
    self.m_ejectionList = {}
    self.m_mediumState = MediumState.Normal
end

function Medium10642:DoUpdate(deltaMS)
    local owner = self:GetOwner()
    if not owner or not owner:IsLive() then
        self:Clear()
        return 
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        self:Clear()
        return
    end

    if self.m_mediumState == MediumState.Normal then
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
            self.m_mediumState = MediumState.Hurt
        end

    elseif self.m_mediumState == MediumState.Hurt then
        self:ArriveDest()
    end
end


function Medium10642:Clear()
    self.m_ejectionCount = 0
    self.m_ejectionInjure = 0
    self.m_ejectionList = {}
    self:Over()
end

function Medium10642:ArriveDest()
    self:Hurt()
end

function Medium10642:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local skillCfg = self:GetSkillCfg()

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        if self.m_ejectionCount < self.m_skillBase:Y() then
            self:EjectionOther(target, performer)
        else
            self:Clear()
        end
        return
    end
    
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        local time = FixIntMul(self.m_skillBase:A(), 1000)
        local statusDingShen = StatusFactoryInst:NewStatusDingShen(self.m_giver, time) 
        statusDingShen:SetMergeRule(StatusEnum.MERGERULE_LONGER_LEFT)
        local addSuc = self:AddStatus(performer, target, statusDingShen)

        if addSuc then
            local intervalDebuff = target:GetStatusContainer():GetChengyuLongTimeIntervalDebuff()
            if intervalDebuff then
                intervalDebuff:SyncLeftMS(time)
            end
        end
    end

    if self.m_ejectionCount < self.m_skillBase:Y() then
        self:EjectionOther(target, performer)
    else
        self:Clear()
    end
end


function Medium10642:EjectionOther(target, performer)
    local nextTarget = self:SelectOneActor(target, performer)
    if nextTarget and nextTarget:IsLive() then
        self.m_param.targetActorID = nextTarget:GetActorID()
        self.m_mediumState = MediumState.Normal
    end

    self.m_ejectionCount = FixAdd(self.m_ejectionCount, 1)
end


function Medium10642:SelectOneActor(target, performer)
    local selectTarget = false
    local battleLogic = CtlBattleInst:GetLogic()
    local suitableList = {}

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local targetID = tmpTarget:GetActorID()
            if targetID == self.m_param.targetActorID or self.m_ejectionList[targetID] then
                return
            end

            table_insert(suitableList, targetID)
        end
    )

    local hasSuitable = false
    local count = #suitableList
    if count > 0 then
        local index = FixMod(FixRand(), count)
        index = FixAdd(index, 1)
        local targetID = suitableList[index]
        selectTarget = ActorManagerInst:GetActor(targetID)
        hasSuitable = true
        table_insert(self.m_ejectionList, selectTarget)
    end

    if not hasSuitable then
        local count = #self.m_ejectionList
        if count > 0  then
            local index = FixMod(FixRand(), count)
            index = FixAdd(index, 1)
            local newTargetID = self.m_ejectionList[index]
            selectTarget = ActorManagerInst:GetActor(newTargetID)
        end
    end

    return selectTarget
end

return Medium10642