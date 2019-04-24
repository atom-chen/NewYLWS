local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20612 = BaseClass("Skill20612", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")


function Skill20612:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1), pos.z)
    pos:Add(forward)

    local normalFlyParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 20,
    }
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20612, 67, giver, self, pos, forward, normalFlyParam)
end


return Skill20612