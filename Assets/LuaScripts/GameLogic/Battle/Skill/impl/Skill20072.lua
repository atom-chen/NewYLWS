
local MediumManagerInst = MediumManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20072 = BaseClass("Skill20072", SkillBase)

function Skill20072:Perform(performer, target, performPos, special_param)
    
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    if not target:IsValid() then
        return
    end
    
    -- todo pos
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
    pos:Add(forward * 1.13)
    pos:Add(performer:GetRight() * -0.01)
    local giver = StatusGiver.New(performer:GetActorID(), 20072)
    
    local atkINCPercent = false

    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 21,
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20072, 9, giver, self, pos, forward, mediaParam)
end

return Skill20072