local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixNormalize = FixMath.Vector3Normalize
local CtlBattleInst = CtlBattleInst
local IsInRect = SkillRangeHelper.IsInRect

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10221 = BaseClass("Medium10221", LinearFlyToPointMedium)

function Medium10221:OnMove(dir)
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local skillLevel = self.m_skillBase:GetLevel()
    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local performDir = performer:GetForward()
    local performerPos = performer:GetPosition()
    local normalizedDir = FixNormalize(dir)
    local pos = self.m_position + normalizedDir
    local half1 = FixDiv(skillCfg.dis1, 2)
    
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInRect(tmpTarget:GetPosition(), tmpTarget:GetRadius(), half1, 1, pos, normalizedDir) then
                return
            end
            
            local targetID = tmpTarget:GetActorID()
            if performer:Has10221Target(targetID) then
                return
            end

            performer:Add10221TargetID(targetID)

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end


            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
            if injure > 0 then
                local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)

                tmpTarget:OnBeatBack(performer, self.m_skillBase:E())
            end
        end
    )
end


function Medium10221:ArriveDest()
    local performer = self:GetOwner()
    if not performer then
        self:Over()
        return
    end
    performer:Clear10221TargetID()
end

return Medium10221