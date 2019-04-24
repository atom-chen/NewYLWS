local StatusGiver = StatusGiver
local MediumManagerInst = MediumManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local MediumEnum = MediumEnum

local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill10436 = BaseClass("Skill10436", AtkFunc1)

function Skill10436:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
    pos:Add(performer:GetRight() * -0.01)

    local giver = StatusGiver.New(performer:GetActorID(), 10436)
    
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
        targetActorID = target:GetActorID(),
    }
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10436, 16, giver, self, pos, forward, mediaParam)
end

return Skill10436