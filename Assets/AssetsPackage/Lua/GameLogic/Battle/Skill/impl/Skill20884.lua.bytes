local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixNewVector3 = FixMath.NewFixVector3

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20884 = BaseClass("Skill20884", SkillBase)

function Skill20884:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local forward = performer:GetForward()
    local pos = performer:GetPosition() 
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward *0.4)

    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)

    local targetActorID = target:GetActorID()
    local mediaParam = {
        targetActorID = targetActorID,
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
        targetPos = performPos
    } 

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_2088ATK, 76, giver, self, pos, forward, mediaParam) 
end

return Skill20884