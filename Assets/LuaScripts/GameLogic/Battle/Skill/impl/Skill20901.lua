
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixMul = FixMath.mul 
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20901 = BaseClass("Skill20901", SkillBase)

function Skill20901:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then 
        return 
    end   
    
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(performPos.x, performPos.y, performPos.z)

    local giver = StatusGiver.New(performer:GetActorID(), 20141)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 130,
        targetPos = performPos,
    }
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20141, 81, giver, self, pos, forward, mediaParam)
end

return Skill20901