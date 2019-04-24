local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local CtlBattleInst = CtlBattleInst
local IsInCircle = SkillRangeHelper.IsInCircle

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10441 = BaseClass("Medium10441", LinearFlyToPointMedium)

function Medium10441:__init()
    self.m_interval = 0
    self.m_continueTime = 0
end

function Medium10441:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)

    self.m_interval = 1000
    self.m_continueTime = FixIntMul(self.m_skillBase:E(), 1000)
end

function Medium10441:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local performPos = self.m_param.targetPos
    local radius = self.m_skillBase:B()
    local reducePercent = self.m_skillBase:X()

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(performPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, reducePercent)
            if injure > 0 then
                local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)
            end
        end
    )
end


function Medium10441:MoveToTarget(deltaMS)
    self.m_interval = FixSub(self.m_interval, deltaMS)
    if self.m_interval <= 0 then
        self.m_interval = FixAdd(self.m_interval, 1000)
        self:Hurt()
    end

    self.m_continueTime = FixSub(self.m_continueTime, deltaMS)
    if self.m_continueTime <= 0 then
        self:Over()
    end

    return false
end


return Medium10441