local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local FixMul = FixMath.mul
local CtlBattleInst = CtlBattleInst
local IsInRect = SkillRangeHelper.IsInRect
local FixDiv = FixMath.div
local FixNewVector3 = FixMath.NewFixVector3

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20271 = BaseClass("Skill20271", SkillBase)


function Skill20271:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    -- 圆月连斩 
    -- 挥舞弯刀，对选中区域连续发射5道刀风，每次造成{x1}%的物理伤害。
    -- 挥舞弯刀，对选中区域连续发射5道刀风，每次造成{x2}%的物理伤害。最后一道刀风可将敌人击退{A}米。
    
    local factory = StatusFactoryInst
    local btLogic = CtlBattleInst:GetLogic()
    local StatusGiverNew = StatusGiver.New
    local half1 = FixDiv(self.m_skillCfg.dis1, 2)
    local half2 = FixDiv(self.m_skillCfg.dis2, 2)
    local forward = performer:GetForward()
    local dir = FixNewVector3(forward.x, forward.y, forward.z)
    local selfPos = performer:GetPosition()
    dir:Mul(half2)
    dir:Add(selfPos)
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not btLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInRect(tmpTarget:GetPosition(), tmpTarget:GetRadius(), half1, half2, dir, forward) then
                return
            end

            local judge = AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if IsJudgeEnd(judge) then
                return  
            end

            local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = StatusGiverNew(performer:GetActorID(), 20271)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
            end

            if self.m_level >= 2 and special_param.keyFrameTimes == 5 then
                tmpTarget:OnBeatBack(performer, self:A())
            end
        end
    )

    
end

return Skill20271