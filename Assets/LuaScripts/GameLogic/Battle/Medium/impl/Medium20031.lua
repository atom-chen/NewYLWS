local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixNormalize = FixMath.Vector3Normalize
local ACTOR_ATTR = ACTOR_ATTR

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium20031 = BaseClass("Medium20031", LinearFlyToTargetMedium)

function Medium20031:DoUpdate(deltaMS)
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

function Medium20031:ArriveDest()
    self:Hurt()
end

function Medium20031:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    if not battleLogic or not skillCfg or not self.m_skillBase then
        return
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    if not CtlBattleInst:GetLogic():IsEnemy(performer, target, BattleEnum.RelationReason_SKILL_RANGE) then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        if self.m_level == 2 then
            local performerCurHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            local performerMaxHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
            local hpPercent = FixDiv(performerCurHP, performerMaxHP)
            if hpPercent < self.m_skillBase:A() then
                injure = FixMul(injure, FixAdd(1, FixDiv(self.m_skillBase:B(), 100)))
            end
        end
        
        local statusHP = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                    judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, statusHP)
    end
end


return Medium20031