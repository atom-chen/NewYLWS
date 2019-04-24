local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20111 = BaseClass("Skill20111", SkillBase)

function Skill20111:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return  
    end
    
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
    pos:Add(forward * 1.13)
    pos:Add(performer:GetRight() * -0.01)

    local giver = StatusGiver.New(performer:GetActorID(), 20111)
    
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
    } 
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20111, 63, giver, self, pos, forward, mediaParam)
end 

return Skill20111





