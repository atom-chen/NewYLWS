local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10214 = BaseClass("Skill10214", SkillBase)

function Skill10214:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.162), pos.z)
    pos:Add(performer:GetRight() * -0.041)
    pos:Add(forward * 2.1)

    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_1021ATK, 73, giver, self, pos, forward, mediaParam)
end

return Skill10214