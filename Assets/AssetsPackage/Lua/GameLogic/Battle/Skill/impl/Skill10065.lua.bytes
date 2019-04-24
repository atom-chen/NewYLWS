
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10065 = BaseClass("Skill10065", SkillBase)

function Skill10065:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    local y = 0
    if special_param.keyFrameTimes <= 2 then
        y = FixAdd(pos.y, 1.5)
    else
        y = FixAdd(pos.y, 1.2)
    end
    pos = FixNewVector3(pos.x, y, pos.z) 
    local tRight = performer:GetRight() * -0.01
    pos:Add(tRight)
    
    local giver = StatusGiver.New(performer:GetActorID(), 10062)
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_1006ATK, 54, giver, self, pos, forward, mediaParam)
end

return Skill10065