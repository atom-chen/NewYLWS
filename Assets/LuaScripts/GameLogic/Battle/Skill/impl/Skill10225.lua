local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10225 = BaseClass("Skill10225", SkillBase)

function Skill10225:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 0.7), pos.z)
    pos:Add(performer:GetRight() * -0.267)
    pos:Add(forward * 1.5)

    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
    }

    local mediaID = 2
    local fengleichi = performer:GetStatusContainer():GetGuojiaFengleichi()
    if fengleichi then
        mediaID = 82
        mediaParam.radius = fengleichi:GetRadius()
        mediaParam.hurtPercent = fengleichi:GetHurtPercent()
    end

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_1022ATK, mediaID, giver, self, pos, forward, mediaParam)
end

return Skill10225