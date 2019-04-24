local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill771 = BaseClass("Skill771", SkillBase)
local StatusGiver = StatusGiver
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst

function Skill771:__init()
end

function Skill771:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end
    
    local pos = performer:GetPosition()
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local forward = performer:GetForward()
    local targetPos = forward * 18
    targetPos:Add(performer:GetPosition())

    local mediaParam = {
        targetActorID = target and target:GetActorID() or 0,
        keyFrame = special_param.keyFrameTimes,
        speed = 12,
        targetPos = targetPos,--todo
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_GUANYU_WATER, 7, giver, self, pos, forward, mediaParam)
end

return Skill771