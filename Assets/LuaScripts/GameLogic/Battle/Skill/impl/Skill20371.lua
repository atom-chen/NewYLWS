
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixNewVector3 = FixMath.NewFixVector3

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20371 = BaseClass("Skill20371", SkillBase)

function Skill20371:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 4), pos.z)
    pos:Add(forward * -2)
    performPos = FixNewVector3(performPos.x, FixSub(performer:GetPosition().y, 1.1), performPos.z)

    local giver = StatusGiver.New(performer:GetActorID(), 20371)
    local mediaID = 46
    if self.m_level >= 2 then
        mediaID = 48
    end
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 16,
        targetPos = performPos,
    }
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20371, mediaID, giver, self, pos, forward, mediaParam)
end

return Skill20371