local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill22002 = BaseClass("Skill22002", SkillBase)

function Skill22002:Perform(performer, target, performPos, special_param)
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
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_22002, 91, giver, self, pos, forward, mediaParam)

end

return Skill22002


