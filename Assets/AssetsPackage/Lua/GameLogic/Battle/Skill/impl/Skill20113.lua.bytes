local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20113 = BaseClass("Skill20113", SkillBase)

function Skill20113:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward *0.5)
    
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    
    local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 13, BattleEnum.HURTTYPE_PHY_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 63, giver, self, pos, forward, normalFlyParam)
end


return Skill20113