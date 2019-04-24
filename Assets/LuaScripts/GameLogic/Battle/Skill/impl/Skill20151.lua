
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
local Skill20151 = BaseClass("Skill20151", SkillBase)

function Skill20151:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then 
        return 
    end 
 
    local pos = performer:GetPosition() 
    local forward = performer:GetForward()  
    pos = FixNewVector3(pos.x + 1, pos.y, pos.z + 1)

    local giver = StatusGiver.New(performer:GetActorID(), 20151)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 230,
        targetPos = pos,
    }  
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20151, 97, giver, self, pos, forward, mediaParam)
end

return Skill20151






