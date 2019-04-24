
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10354 = BaseClass("Skill10354", SkillBase)

function Skill10354:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward *0.4)
    
    local giver = StatusGiver.New(performer:GetActorID(), 10354)

    local normalFlyParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 30,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_1035ATK, 14, giver, self, pos, forward, normalFlyParam)
end



return Skill10354