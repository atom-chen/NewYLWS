
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3


local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill12142 = BaseClass("Skill12142", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill12142:Perform(performer, target, performPos, special_param)
    if not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x + 0.4, FixAdd(pos.y, 2), pos.z)
    pos:Add(performer:GetRight() * -0.01)

    local giver = StatusGiver.New(performer:GetActorID(), 10341)
    
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 18,
        varSpeed = 5
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_12142, 44, giver, self, pos, forward, mediaParam)
end

return Skill12142