
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill11114 = BaseClass("Skill11114", SkillBase)

function Skill11114:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.5), pos.z) + forward * 0.5 + performer:GetRight() * -0.01
    
    local giver = StatusGiver.New(performer:GetActorID(), 11114)
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 15,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_11114, 50, giver, self, pos, forward, mediaParam)
end

return Skill11114