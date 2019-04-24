local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixNormalize = FixMath.Vector3Normalize

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium20032 = BaseClass("Medium20032", LinearFlyToTargetMedium)

function Medium20032:InitParam(param)
    LinearFlyToTargetMedium.InitParam(self, param)

    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    local performer = self:GetOwner()

    if performer and performer:IsLive() and target and target:IsLive() then
        self.m_distance = (target:GetPosition() - self.m_position):Magnitude()
    end
end


function Medium20032:DoUpdate(deltaMS)
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
    
    local moveDis = FixMul(deltaS, self.m_param.speed) 
    local dir = target:GetPosition() - self.m_position

    local disSqr = dir:SqrMagnitude()
    local targetRadius = target:GetRadius()

    local middlePoint = target:GetMiddlePoint()
    if middlePoint then
        self:LookatTransformOnlyShow(middlePoint)
    end

    local curDis = dir:Magnitude()
    local angle = FixMul(FixDiv(curDis, self.m_distance), 50)
    self:Rotate(FixMul(angle, -1), 0, 0)

    if disSqr > FixMul(targetRadius, targetRadius) then
        local deltaV = FixNormalize(dir)
        self:SetNormalizedForward_OnlyLogic(deltaV)

        deltaV:Mul(moveDis) 
        self:MovePosition_OnlyLogic(deltaV)
        self:OnMove(dir)
        self:MoveOnlyShow(moveDis)
    else
        self:ArriveDest()
        self:Over()
        return
    end
end


function Medium20032:ArriveDest()
    self:Hurt()
end

function Medium20032:Hurt()
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

    if not battleLogic:IsEnemy(performer, target, BattleEnum.RelationReason_SKILL_RANGE) then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    if self.m_skillBase:GetLevel() >= 2 then
        -- 任意一名敌人在{b}秒内如果连续被浪射射中，将陷入{c}秒的眩晕状态
        local langsheMark = target:GetStatusContainer():GetLangsheMark()
        if langsheMark then
            local curTime = battleLogic:GetSinceStartMS()
            if langsheMark:GetMarkCount() > 1 then
                local deltaMS = FixSub(curTime, langsheMark:GetMarkStartTime())
                if deltaMS <= FixMul(self.m_skillBase:B(), 1000) then
                    local giver = StatusGiver.New(performer:GetActorID(), 20032)
                    local stunBuff = StatusFactoryInst:NewStatusStun(giver, FixMul(self.m_skillBase:C(), 1000))
                    self:AddStatus(performer, target, stunBuff)
                    langsheMark:ClearMarkData()
                end
            else
                langsheMark:AddMarkCount()
                if langsheMark:GetMarkStartTime() == 0 then
                    langsheMark:SetMarkStartTime(curTime)
                end
            end
        else
            local giver = StatusGiver.New(performer:GetActorID(), 20032)
            langsheMark = StatusFactoryInst:NewStatusLangsheMark(giver)
            self:AddStatus(performer, target, langsheMark)
        end
    end

    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local statusHP = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                    judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, statusHP)
    end

end

return Medium20032