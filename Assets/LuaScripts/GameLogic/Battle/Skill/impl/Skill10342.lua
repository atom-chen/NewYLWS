local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local Formular = Formular
local CalcInjure = Formular.CalcInjure
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local IsJudgeEnd = Formular.IsJudgeEnd
local MediumManagerInst = MediumManagerInst
local FixSub = FixMath.sub
local table_insert = table.insert

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10342 = BaseClass("Skill10342", SkillBase)

function Skill10342:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end
    -- 1 
    -- 大乔向{A}米距离内最远的敌人挥出一道旋风，造成{x1}（+{E}%法攻)点法术伤害，并为旋风路径上的己方角色回复{y1}（+{E}%法攻)点生命。
    -- 2 - 5
    -- 被复苏之风影响到的己方角色，攻击速度提升{z2}%，持续{B}秒。
    -- 6
    -- 大乔每次挥出的旋风变为{C}道。

    local pos = performer:GetPosition()
    local forward = performer:GetForward()

    local targetPos = nil

    if target and target:IsLive() then
        targetPos = FixNormalize(target:GetPosition() - pos)
        targetPos:Mul(self.m_skillCfg.dis2)
        targetPos:Add(pos)
    else
        targetPos = FixNormalize(performPos - pos)
        targetPos:Mul(self.m_skillCfg.dis2)
        targetPos:Add(pos)
    end

    local giver = StatusGiver.New(performer:GetActorID(), 10342)
    
    local mediaParam = {
        targetPos = targetPos,
        keyFrame = special_param.keyFrameTimes,
        speed = 22,
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10342, 26, giver, self, pos, forward, mediaParam)

    if self.m_level >= 6 then
        local count = FixSub(self:C(), 1)
        
        local targetIDList = {}
        for i=1, count do
            
            local otherTarget = self:SelectOtherTarget(performer, target, targetIDList)
            if otherTarget and otherTarget:IsLive() then

                targetPos = nil
                targetPos = FixNormalize(otherTarget:GetPosition() - pos)
                targetPos:Mul(self.m_skillCfg.dis2)
                targetPos:Add(pos)

                mediaParam = {
                    targetPos = targetPos,
                    keyFrame = special_param.keyFrameTimes,
                    speed = 22,
                }

                local param = {
                    type = MediumEnum.MEDIUMTYPE_10342,
                    speed = 26,
                    giver = giver,
                    skillbase = self,
                    pos = pos,
                    forward = forward,
                    mediaParam = mediaParam
                }

                performer:SetPatam(param)
                
                targetIDList[otherTarget:GetActorID()] = true

                local judge = Formular.AtkRoundJudge(performer, otherTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
                if IsJudgeEnd(judge) then
                    return  
                end
            
                local injure = CalcInjure(performer, otherTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
                if injure > 0 then
                    local giver = StatusGiver.New(performer:GetActorID(), 10342)
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, otherTarget, status)
                end
            else
                
            end
        end
    end

    if target and target:IsLive() then
        local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
        if IsJudgeEnd(judge) then
            return  
        end
    
        local injure = CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
        if injure > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 10342)
            local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
            self:AddStatus(performer, target, status)
        end
    end
end


function Skill10342:SelectSkillTarget(performer, target)
    if not performer then
        return
    end

    local minDistance2 = 0
    local newTarget = false

    local ctlBattle = CtlBattleInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local dis2 = (performer:GetPosition() - tmpTarget:GetPosition()):SqrMagnitude()
            if dis2 < FixMul(self:A(), self:A()) then
                if dis2 > minDistance2 then
                    minDistance2 = dis2
                    newTarget = tmpTarget
                end
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition() - performer:GetPosition()
    end
    return nil, nil
end


function Skill10342:SelectOtherTarget(performer, target, targetIDList) 
    local minDistance2 = 0
    local newTarget = false

    local ctlBattle = CtlBattleInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local targetID = tmpTarget:GetActorID()
            if targetIDList[targetID] then
                return
            end

            if tmpTarget:GetActorID() == targetID then
                return
            end

            local dis2 = (performer:GetPosition() - tmpTarget:GetPosition()):SqrMagnitude()
            if dis2 < FixMul(self:A(), self:A()) then
                if dis2 > minDistance2 then
                    minDistance2 = dis2
                    newTarget = tmpTarget
                end
            end
        end
    )

    if not newTarget then
        newTarget = target
    end

    return newTarget
end

return Skill10342