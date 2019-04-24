local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10215 = BaseClass("Skill10215", SkillBase)

function Skill10215:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.051), pos.z)
    pos:Add(performer:GetRight() * 0.168)
    pos:Add(forward * 1.392)

    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_1021ATK, 73, giver, self, pos, forward, mediaParam)
end

return Skill10215