local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill40073 = BaseClass("Skill40073", SkillBase)

function Skill40073:Perform(performer, target, performPos, special_param)
    if not performer or not target then 
        return 
    end
    local time = 0.57 -- test 调试
    local distance = (target:GetPosition() - performer:GetPosition()):Magnitude()
    local targetRadius = target:GetRadius()
    if distance > targetRadius then
        local speed = FixDiv(FixSub(distance, targetRadius), time)
        local performerMovehelper = performer:GetMoveHelper()
        if performerMovehelper then
            local dir = target:GetPosition() - performer:GetPosition()
            -- dir.y = 0
            dir = FixNormalize(dir)
            distance = distance - targetRadius *2

            dir:Mul(distance)
            dir:Add(performer:GetPosition())
            
            local targetPos = dir

            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = performer:GetPosition():GetXYZ()
                local x2, y2, z2 = targetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    targetPos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
                end
            end

            local targetID = target:GetActorID()
            local performerID = performer:GetActorID()

            performerMovehelper:Stop()
            performerMovehelper:Start({ targetPos }, speed, function()
                local tujiTarget = ActorManagerInst:GetActor(targetID)
                local tujiPerformer = ActorManagerInst:GetActor(performerID)
                if tujiTarget and tujiTarget:IsLive() and tujiPerformer and tujiPerformer:IsLive() then
                    local tujiHurt = tujiPerformer:GetTujiHurt()
                    local giver = StatusGiver.New(tujiPerformer:GetActorID(), 40073)
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, tujiHurt), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, 1)
                    self:AddStatus(tujiPerformer, tujiTarget, status)
                end
            end, true)
        end
    end
end




return Skill40073