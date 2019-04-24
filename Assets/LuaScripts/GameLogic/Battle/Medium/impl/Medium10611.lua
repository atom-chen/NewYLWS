local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixNormalize = FixMath.Vector3Normalize
local Quaternion = Quaternion
local CtlBattleInst = CtlBattleInst
local IsInRect = SkillRangeHelper.IsInRect

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10611 = BaseClass("Medium10611", LinearFlyToPointMedium)

function Medium10611:OnMove(dir)
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
            if performer:Has10611Target(targetID) then
                return
            end

            performer:Add10611TargetID(targetID)
            tmpTarget:AddEffect(20001)

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local hurtMul = 1
            if skillLevel == 1 then
                tmpTarget:AddEffect(106106)
            elseif skillLevel == 2 then
                tmpTarget:AddEffect(106107)
            elseif skillLevel == 3 then
                tmpTarget:AddEffect(106108)
            elseif skillLevel == 4 then
                tmpTarget:AddEffect(106109)
            elseif skillLevel == 5 then
                tmpTarget:AddEffect(106110)
            elseif skillLevel == 6 then
                tmpTarget:AddEffect(106111)
            end

            if skillLevel >= 2 then
                --A值改为z值
                hurtMul = FixAdd(FixDiv(self.m_skillBase:Z(), 100), hurtMul)
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:Y())
            if injure > 0 then
                local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)
            end

            local giver = statusGiverNew(performer:GetActorID(), 10611)
            local status = factory:NewStatusYujinMark(giver, FixIntMul(self.m_skillBase:X(), 1000), hurtMul)
            status:SetCanClearByOther(false)
            self:AddStatus(performer, tmpTarget, status)
        end
    )
end


function Medium10611:ArriveDest()
    local performer = self:GetOwner()
    if not performer then
        self:Over()
        return
    end
    performer:Clear10611TargetID()
end

return Medium10611