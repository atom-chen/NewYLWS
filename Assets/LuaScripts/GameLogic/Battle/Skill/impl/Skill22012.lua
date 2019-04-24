local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill22012 = BaseClass("Skill22012", SkillBase)

function Skill22012:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end 
    
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1), pos.z) 
    local giver = StatusGiver.New(performer:GetActorID(), 22002)
    
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_22012, 91, giver, self, pos, forward, mediaParam)

end

return Skill22012


