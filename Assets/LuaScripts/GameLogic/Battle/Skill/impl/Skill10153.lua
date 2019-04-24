local StatusGiver = StatusGiver
local MediumManagerInst = MediumManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10153 = BaseClass("Skill10153", SkillBase)
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

function Skill10153:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    performer:AddEffect(101503)

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward)

    local normalFlyParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 20,
    }
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10153, 62, giver, self, pos, forward, normalFlyParam)

    performer:ActiveFenshenSkill(10153, target:GetActorID())
end


return Skill10153