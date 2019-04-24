local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixNormalize = FixMath.Vector3Normalize
local IsInRect = SkillRangeHelper.IsInRect

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium20481 = BaseClass("Medium20481", LinearFlyToPointMedium)

function Medium20481:__init()
    self.m_enemyList = {}  --id[]
end

function Medium20481:OnMove(dir)
    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    local performer = self:GetOwner()
    if not performer then
        return
    end

    if not battleLogic or not skillCfg or not self.m_skillBase then
        return
    end

    local skillLevel = self.m_skillBase:GetLevel()

    local normalizedDir = FixNormalize(self.m_param.targetPos - performer:GetPosition())
    normalizedDir:Mul(0.1)
    normalizedDir:Add(self.m_position)
    local performDir = FixNormalize(self.m_param.targetPos - performer:GetPosition())
    local halfDis1 = FixDiv(skillCfg.dis1, 2)
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local targetID = tmpTarget:GetActorID()
            if self.m_enemyList[targetID] then
                return
            end

            if not IsInRect(tmpTarget:GetPosition(), tmpTarget:GetRadius(), halfDis1, 0.1, normalizedDir, performDir) then
                return
            end

            self.m_enemyList[targetID] = true

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
            if injure > 0 then
                local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                        judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)

                tmpTarget:OnBeatBack(performer, self.m_skillBase:B())
            end

            if skillLevel >= 2 then
                local injureInterval = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:Y())
                if injureInterval > 0 then
                    local intervalStatus = StatusFactoryInst:NewStatusIntervalHP(self.m_giver, FixMul(injureInterval, -1), 1000, self.m_skillBase:C())
                    self:AddStatus(performer, tmpTarget, intervalStatus)
                end
            end
        end
    )
end



-- return 是否到达目的地
function Medium20481:MoveToTarget(deltaMS)
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

        if leftDistance < moveDis then
            return true
        end
    end

    return false
end

return Medium20481