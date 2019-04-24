 local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local FixNormalize = FixMath.Vector3Normalize

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill22004 = BaseClass("Skill22004", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill22004:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end 
    local pos = performer:GetPosition() 
    local forward = performer:GetForward()   
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)   
    
    local isAchieved = performer:Is22003HurtCountAchieved()    
    if isAchieved then
        local tPos = target:GetPosition()
        local targetPos = FixNormalize(tPos - pos)
        targetPos:Mul(performer:Get22003A())              
        targetPos:Add(tPos)  
        pos = FixNewVector3(pos.x, pos.y + 0.8, pos.z) 
        targetPos = FixNewVector3(targetPos.x, targetPos.y + 0.8, targetPos.z) 

        local mediaParam = { 
            keyFrame = special_param.keyFrameTimes,
            speed = 13,
            targetPos = targetPos, 
        }
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_22003, 92, giver, self, pos, forward, mediaParam)
        performer:Clear22003HurtCount()
    else 
        pos = FixNewVector3(pos.x, pos.y + 0.8, pos.z)
        local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 13, BattleEnum.HURTTYPE_PHY_HURT)
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 89, giver, self, pos, forward, normalFlyParam)
    end 
end

return Skill22004