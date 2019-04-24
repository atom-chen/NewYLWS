local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20033 = BaseClass("Skill20033", SkillBase)

function Skill20033:Perform(performer, target, performPos, special_param)

    if not self.m_skillCfg or not performer or not target then 
        return 
    end
    
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.5), pos.z)
    pos:Add(forward * 1.13)
    pos:Add(performer:GetRight() * -0.01)
    
    local giver = StatusGiver.New(performer:GetActorID(), 20033)
    -- local mediaID = self:MediaID()

    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
        targetActorID = target:GetActorID(),
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20033, 1, giver, self, pos, forward, mediaParam)
        
end


return Skill20033