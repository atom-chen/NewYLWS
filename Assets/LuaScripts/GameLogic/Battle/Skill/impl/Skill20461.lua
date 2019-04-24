local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20461 = BaseClass("Skill20461", SkillBase)

function Skill20461:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    if special_param.keyFrameTimes == 1 then
        local newPos = FixNewVector3(performer:GetPosition().x, performer:GetOrignalY(), performer:GetPosition().z)
        performer:SetPosition(newPos)
    end

    if special_param.keyFrameTimes > 1 and special_param.keyFrameTimes <= 8 then
        local distance = 0
        if special_param.keyFrameTimes == 2 then
            local movehelper = performer:GetMoveHelper()
            if movehelper then
                local radius = FixMul(performer:GetRadius(), 2)
                local moveTargetPos = performPos
                moveTargetPos:Mul(FixSub(self.m_skillCfg.dis2, radius))
                moveTargetPos:Add(performer:GetPosition())
                
                local pathHandler = CtlBattleInst:GetPathHandler()
                if pathHandler then
                    local x,y,z = performer:GetPosition():GetXYZ()
                    local x2, y2, z2 = moveTargetPos:GetXYZ()
                    local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                    if hitPos then
                        moveTargetPos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
                    end
                end
                
                performer:SetDesPos(moveTargetPos)
                distance = (moveTargetPos - performer:GetPosition()):Magnitude()
                local speed = FixDiv(distance, 0.587)
                movehelper:Stop()
                movehelper:Start({ moveTargetPos }, speed, nil, true)
            end
        end

        local battleLogic = CtlBattleInst:GetLogic()
        local factory = StatusFactoryInst
        local desPos = performer:GetDesPos()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not self:InRange(performer, tmpTarget, performPos, performer:GetOrignalPos()) then
                    return
                end

                local targetID = tmpTarget:GetActorID()
                if performer:HasEnemyList(targetID) then
                    return
                end

                local dis2 = (performer:GetPosition() - tmpTarget:GetPosition()):SqrMagnitude()
                if dis2 > 8 then
                    return
                end
                performer:AddEnemyListByTargetID(targetID)

                -- local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
                -- if Formular.IsJudgeEnd(judge) then
                --     return  
                -- end

                local distance1 = (desPos - tmpTarget:GetPosition()):Magnitude()
                tmpTarget:OnBeatBack(performer, distance1)
            end
        )
    end

    if special_param.keyFrameTimes == 9 then

        BattleCameraMgr:Shake(1)

        local enemyList = performer:GetEnemyList()
        for targetID,_ in pairs(enemyList) do
            local target = ActorManagerInst:GetActor(targetID)
            if target and target:IsLive() then
                local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
                if injure > 0 then
                    local giver = StatusGiver.New(performer:GetActorID(), 20461)
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                        judge, special_param.keyFrameTimes)
                    
                    self:AddStatus(performer, target, status)
                    target:AddEffect(204602)
                end
            end
        end

        performer:ClearEnemyList()
    end
end

return Skill20461