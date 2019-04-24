
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver 
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum 
local FixAdd = FixMath.add

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill22013 = BaseClass("Skill22013", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")
 
function Skill22013:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end 
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1), pos.z) 
    local giver = StatusGiver.New(performer:GetActorID(), 22013)
    
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_22013, 89, giver, self, pos, forward, mediaParam)
end

return Skill22013


