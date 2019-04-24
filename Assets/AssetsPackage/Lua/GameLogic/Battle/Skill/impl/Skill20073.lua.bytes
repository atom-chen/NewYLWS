local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20073 = BaseClass("Skill20073", SkillBase)

function Skill20073:Perform(performer, target, performPos, special_param)

    if not self.m_skillCfg or not performer or not target then 
        return 
    end
    
    -- todo pos
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
    pos:Add(forward * 1.13)
    pos:Add(performer:GetRight() * -0.01)
    local giver = StatusGiver.New(performer:GetActorID(), 20073)
    
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20073, 9, giver, self, pos, forward, mediaParam)
end


return Skill20073