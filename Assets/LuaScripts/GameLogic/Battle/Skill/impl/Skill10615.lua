local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10615 = BaseClass("Skill10615", SkillBase)

function Skill10615:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    local targetID = target:GetActorID()
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if targetID == tmpTarget:GetActorID() then
                return
            end

            local tmpTargetMark = tmpTarget:GetStatusContainer():GetYujinMark()
            if tmpTargetMark then
                local tmpMul = tmpTargetMark:GetHurtMul()
                self:CreateMedium(performer, tmpTarget, special_param, tmpMul) 
            end
        end
    )

    local mul = 1
    local targetMark = target:GetStatusContainer():GetYujinMark()
    if targetMark then
        mul = targetMark:GetHurtMul()
    end
    self:CreateMedium(performer, target, special_param, mul)  
end

function Skill10615:CreateMedium(performer, target, special_param, hurtMul)
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 0.8), pos.z) 
    pos:Add(forward * 0.5)
    pos:Add(performer:GetRight() * -0.01)
    
    local giver = StatusGiver.New(performer:GetActorID(), 10615)
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 15,
        hurtMul = hurtMul,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_1061ATK, 52, giver, self, pos, forward, mediaParam)
end


return Skill10615